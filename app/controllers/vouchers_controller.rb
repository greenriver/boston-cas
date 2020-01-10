###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class VouchersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_vouchers!
  before_action :require_can_edit_vouchers!, only: [:update, :destroy, :create, :bulk_update]
  before_action :require_can_reject_matches!, only: [:unavailable]
  before_action :set_voucher, only: [:update, :destroy, :unavailable]
  before_action :set_sub_program, only: [:create, :index, :bulk_update, :unavailable]
  before_action :set_program, only: [:index, :bulk_update, :unavailable]
  before_action :set_show_confidential_names

  def index
    @vouchers = @subprogram.vouchers.order(:id)
    @vouchers_for_page = @vouchers.select{|v| v.status_match.blank?}
    @voucher_state = "available or unmatched"
  end

  def create
    new_vouchers = []
    vouchers_to_create = voucher_params[:add_vouchers].to_i.times do
      new_vouchers << Voucher.create(sub_program: @subprogram, creator: @current_user)
    end
    if vouchers_to_create == new_vouchers.length
      flash[:notice] = "#{vouchers_to_create} vouchers added"
      redirect_to action: :index
    else
      flash[:error] = "Please review the form problems below."
      redirect_to action: :index
    end
  end

  def update
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
          unless m.closed?
            if m.client
              m.client.make_available_in(match_route: m.match_route)
            end
            m.delete
          end
        end
        opportunity.update(available: false, available_candidate: false)
        @voucher.update(available: false)
      end
      @subprogram.update_summary!
    else
      flash[:error] = "The selected voucher does not have an active match, and cannot be stopped."
    end
    redirect_to action: :index
  end

  def bulk_update
    if Voucher.advisory_lock_exists?('voucher_bulk_update')
      redirect_to action: :index
    end
    Voucher.with_advisory_lock('voucher_bulk_update') do
      @vouchers = []
      voucher_params[:vouchers_attributes].each do |i,v|
        voucher = @subprogram.vouchers.preload(:status_match).detect {|subp_voucher| subp_voucher.id == v[:id].to_i}
        raise ActiveRecord::NotFound unless voucher
        voucher.assign_attributes(v)
        @vouchers << voucher
      end

      if @vouchers.all?(&:valid?)
        run_match_engine = false
        @vouchers.each do |voucher|
          # check this before we save the voucher
          changed_to_available = voucher.changing_to_available?
          save_success = voucher.save
          if save_success && voucher.available?
            voucher.create_opportunity!(available: true, available_candidate: true) if voucher.opportunity.blank?
          end

          if save_success && changed_to_available
            run_match_engine = true
          end
        end
        Matching::RunEngineJob.perform_later if run_match_engine
        # update the sub_program to reflect changes
        @subprogram.update_summary!
        flash[:notice] = "Vouchers updated"
        redirect_to action: :index
      else # some voucher is invalid
        flash[:alert] = 'Vouchers could not be updated.  Please correct the errors below.'
        @vouchers_for_page = @vouchers.select{|v| ! v.status_match.present?}
        @voucher_state = "available or unmatched"
        render :index
      end
    end
  end

  def destroy
    if @voucher.can_be_destroyed?
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

  private
    def set_voucher
      @voucher = Voucher.find(params[:id].to_i)
    end

    def set_sub_program
      @subprogram = SubProgram.find(params[:sub_program_id].to_i)
    end

    def set_program
      @program = Program.find(params[:program_id].to_i)
    end

    def set_show_confidential_names
      @show_confidential_names = can_view_client_confidentiality? && params[:confidential_override].present?
    end

    # Only allow a trusted parameter "white list" through.
    def voucher_params
      params.require(:sub_program).
        permit(
          :sub_program_id,
          :add_vouchers,
          vouchers_attributes: [:id, :available, :unit_id, :date_available],
        )
    end
end
