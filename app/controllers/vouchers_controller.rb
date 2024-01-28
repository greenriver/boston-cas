###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class VouchersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_vouchers!
  before_action :require_can_edit_vouchers!, only: [:edit, :update, :destroy, :create, :bulk_update]
  before_action :require_can_reject_matches!, only: [:unavailable]
  before_action :require_can_edit_voucher_rules!, only: [:edit, :update]
  before_action :set_voucher, only: [:edit, :update, :destroy, :unavailable, :archive]
  before_action :set_sub_program, only: [:edit, :update, :create, :index, :bulk_update, :unavailable, :archive]
  before_action :set_program, only: [:edit, :update, :index, :bulk_update, :unavailable, :archive]
  before_action :set_show_confidential_names
  include AjaxModalRails::Controller
  include Search

  def index
    @vouchers = @subprogram.vouchers.order(:id)
    @vouchers_for_page = @vouchers.select { |v| v.status_match.blank? && v.archived_at.blank? }
    @voucher_state = 'available or unmatched'
  end

  def create
    new_vouchers = []
    vouchers_to_create = voucher_params[:add_vouchers].to_i.times do
      options = { sub_program: @subprogram, creator: @current_user }
      requirements = WeightingRule.requirements_and_increment!(@subprogram.match_route)
      options[:requirements] = requirements if requirements.present?

      new_vouchers << Voucher.create(options)
    end
    if vouchers_to_create == new_vouchers.length
      flash[:notice] = "#{vouchers_to_create} vouchers added"
    else
      flash[:error] = 'Please review the form problems below.'
    end
    redirect_to action: :index
  end

  def edit
    @modal_size = :lg
  end

  def update
    if @voucher.update(requirement_params)
      redirect_to action: :index
      flash[:notice] = 'voucher successfully updated.'
    else
      render :edit
    end
  end

  # Find the opportunity with this voucher
  # Mark any involved clients as available_candidate (potentially they've been matched up to the limit,
  # deleting this match this frees one up
  # Delete any associated client opportunity matches that aren't complete
  # Remove the opportunity from matching
  # Set the Voucher as available = false
  def unavailable
    opportunity = @voucher.opportunity
    if opportunity.active_matches.exists?
      matches = opportunity.client_opportunity_matches
      Client.transaction do
        matches.each do |m|
          next if m.closed?

          m.client.make_available_in(match_route: m.match_route) if m&.client
          m.delete
        end
        opportunity.update(available: false, available_candidate: false)
        @voucher.update(available: false, date_available: nil)
      end
      @subprogram.update_summary!
    else
      flash[:error] = 'The selected voucher does not have an active match, and cannot be stopped.'
    end
    redirect_to action: :index
  end

  def archive
    # You can only archive vouchers that aren't available
    # You can only archive vouchers that don't have an active match
    opportunity = @voucher.opportunity
    if @voucher.available
      flash[:error] = 'Vouchers must be unavailable to be archived'
    elsif opportunity.active_matches.exists?
      flash[:error] = 'Vouchers be archived if there is an active match'
    else
      @voucher.update(archived_at: Time.current)
      flash[:notice] = 'Voucher archived'

    end
    redirect_to action: :index
  end

  def bulk_update
    redirect_to action: :index if Voucher.advisory_lock_exists?('voucher_bulk_update')
    Voucher.with_advisory_lock('voucher_bulk_update') do
      @vouchers = []
      voucher_params[:vouchers_attributes].each do |_, v|
        voucher = @subprogram.vouchers.preload(:status_match).detect { |subp_voucher| subp_voucher.id == v[:id].to_i }
        raise ActiveRecord::NotFound unless voucher

        voucher.assign_attributes(v)
        @vouchers << voucher
      end

      if @vouchers.all?(&:valid?)
        run_match_engine = false
        @vouchers.each do |voucher|
          # check this before we save the voucher
          changed_to_available = voucher.changing_to_available?
          voucher.made_available_at = Time.current if changed_to_available
          save_success = voucher.save
          if save_success && voucher.available?
            voucher.create_opportunity!(available: true, available_candidate: true) if voucher.opportunity.blank?
          end

          run_match_engine = true if save_success && changed_to_available
        end
        Matching::RunEngineJob.perform_later if run_match_engine
        # update the sub_program to reflect changes
        @subprogram.update_summary!
        flash[:notice] = 'Vouchers updated'
        redirect_to action: :index
      else # some voucher is invalid
        flash[:alert] = 'Vouchers could not be updated.  Please correct the errors below.'
        @vouchers_for_page = @vouchers.select { |v| v.status_match.blank? }
        @voucher_state = 'available or unmatched'
        render :index
      end
    end
  end

  def destroy
    if @voucher.can_be_destroyed?
      @voucher.client_opportunity_matches.proposed.destroy_all
      @voucher.destroy
      flash[:alert] = 'Voucher removed.'
    else
      flash[:alert] = 'Voucher in use and cannot be removed.'
    end
    redirect_to action: :index
  end

  def show_confidential_names?
    @show_confidential_names
  end
  helper_method :show_confidential_names?

  private def set_voucher
    @voucher = Voucher.find(params[:id].to_i)
  end

  private def set_sub_program
    @subprogram = SubProgram.find(params[:sub_program_id].to_i)
  end

  private def set_program
    @program = Program.find(params[:program_id].to_i)
  end

  private def set_show_confidential_names
    @show_confidential_names = can_view_client_confidentiality? && params[:confidential_override].present?
  end

  # Only allow a trusted parameter "white list" through.
  private def voucher_params
    params.require(:sub_program).
      permit(
        :sub_program_id,
        :add_vouchers,
        vouchers_attributes: [:id, :available, :unit_id, :date_available],
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy],
      )
  end

  private def requirement_params
    return {} unless params[:voucher].present?

    params.require(:voucher).
      permit(
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy],
      )
  end

  def search_scope
    @vouchers.preload(:client_opportunity_matches)
  end
end
