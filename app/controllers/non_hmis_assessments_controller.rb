###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class NonHmisAssessmentsController < ApplicationController
  before_action :set_client
  before_action :require_client_permission!, only: [:index, :new, :create]
  before_action :require_can_edit_client!, only: [:new, :create]
  before_action :set_assessment, only: [:show, :edit, :update, :destroy, :unlock]
  before_action :require_can_see_assessment!, only: [:show]
  before_action :require_can_edit_assessment!, only: [:edit, :update, :destroy]
  before_action :require_can_unlock_assessment!, only: [:unlock]
  before_action :set_neighborhoods

  def index
    @assessments = NonHmisAssessment.where(non_hmis_client_id: @non_hmis_client.id)
  end

  def new
    @assessment = build_assessment
  end

  def create
    @assessment = build_assessment
    return redirect_to new_polymorphic_path([@non_hmis_client, :non_hmis_assessment]) if @assessment.requires_assessment_type_choice? && @assessment.assessment_type.blank?

    opts = clean_assessment_params(@assessment.assessment_params(params))

    @assessment.update(opts)
    @non_hmis_client.update(assessed_at: @assessment.entry_date) if @assessment.entry_date
    if @assessment.save
      redirect_to @non_hmis_client
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    opts = clean_assessment_params(@assessment.assessment_params(params))
    if @assessment.update(opts)
      @non_hmis_client.update(assessed_at: @assessment.entry_date) if @assessment.entry_date
      redirect_to @non_hmis_client
    else
      render :edit
    end
  end

  def destroy
    @assessment.destroy
    flash[:notice] = 'Assessment successfully deleted.'

    redirect_to @non_hmis_client
  end

  def unlock
    @assessment.update(locked_until: nil)
    redirect_to @non_hmis_client
  end

  private def clean_assessment_params(assessment_params)
    assessment_params[:assessment_name] = @assessment.for_matching.keys.first
    assessment_params[:income_total_monthly] = assessment_params[:income_total_annual].to_i / 12 if assessment_params[:income_total_annual].present?

    # START current living situation
    # NOTE, this needs to happen before dv_rrh_aggregate since we only allow one of these currently, and that also affects domestic_violence
    if @non_hmis_client.pathways_enabled?
      assessment_params[:domestic_violence] = 0
      assessment_params[:enrolled_in_es] = false
      assessment_params[:enrolled_in_so] = false
    end
    assessment_params[:domestic_violence] = 1 if assessment_params.key?(:setting) && assessment_params[:setting] == 'Actively fleeing DV'
    assessment_params[:enrolled_in_es] = true if assessment_params.key?(:setting) && assessment_params[:setting] == 'Emergency Shelter'
    assessment_params[:enrolled_in_so] = true if assessment_params.key?(:setting) && assessment_params[:setting] == 'Unsheltered'
    # END current living situation

    if assessment_params.key?(:youth_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:youth_rrh_aggregate].in?(['adult', 'both'])
      assessment_params[:youth_rrh_desired] = true if assessment_params[:youth_rrh_aggregate].in?(['youth', 'both'])
      assessment_params.extract![:youth_rrh_aggregate]
    end

    if assessment_params.key?(:dv_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:dv_rrh_aggregate].in?(['non-dv', 'both'])
      if assessment_params[:dv_rrh_aggregate].in?(['dv', 'both'])
        assessment_params[:dv_rrh_desired] = true
        assessment_params[:domestic_violence] = true
      end
      assessment_params.extract![:dv_rrh_aggregate]
    end

    # We're using a varchar as a boolean
    assessment_params[:need_daily_assistance] = nil if assessment_params.key?(:need_daily_assistance) && assessment_params[:need_daily_assistance].to_s == '0'

    assessment_params[:neighborhood_interests] = assessment_params[:neighborhood_interests]&.reject(&:blank?)&.map(&:to_i) if assessment_params[:neighborhood_interests].present?

    # Cleanup Vouchers; for now, just check for the word voucher in the response to 3E
    assessment_params[:have_tenant_voucher] = assessment_params[:pending_housing_placement_type]&.downcase&.include?('voucher')

    assessment_params[:user_id] = current_user.id

    # The assessment type is set when the assessment is built, never from the body.
    assessment_params.delete(:assessment_type)

    assessment_params[:required_number_of_bedrooms] = nil if assessment_params[:required_number_of_bedrooms] == 'on'
    assessment_params[:sro_ok] = nil if assessment_params[:sro_ok] == 'on'

    # apply locking logic
    if @assessment.locked?
      @assessment.lockable_fields.each do |k|
        assessment_params.delete(k)
      end
    else
      @assessment.lock
    end

    assessment_params
  end

  private def require_client_permission!
    return if current_user.can_edit_all_clients?
    return if action_name == 'index' && current_user.can_view_all_covid_pathways?

    permitted = if @non_hmis_client.is_a?(IdentifiedClient)
      current_user.can_enter_identified_clients? || current_user.can_manage_identified_clients? || current_user.can_manage_all_identified_clients?
    else
      current_user.can_enter_deidentified_clients? || current_user.can_manage_deidentified_clients? || current_user.can_manage_all_deidentified_clients?
    end
    not_authorized! unless permitted
  end

  private def require_can_edit_client!
    not_authorized! unless @non_hmis_client.editable_by?(current_user)
  end

  private def require_can_edit_assessment!
    not_authorized! unless @assessment&.editable_by?(current_user)
  end

  private def require_can_see_assessment!
    not_authorized! unless @assessment&.viewable_by?(current_user)
  end

  private def require_can_unlock_assessment!
    not_authorized! unless @assessment&.unlockable_by?(current_user)
  end

  private def build_assessment
    assessment = @non_hmis_client.assessment_type.constantize.new(agency_id: current_user.agency_id, non_hmis_client_id: @non_hmis_client.id)
    return assessment unless assessment.requires_assessment_type_choice?

    requested_type = params[:assessment_type].to_s
    assessment.assessment_type = requested_type if assessment.assessment_type_options.keys.map(&:to_s).include?(requested_type)
    assessment
  end

  private def set_client
    client_scope = nil
    client_id = nil
    if params[:identified_client_id]
      client_id = params[:identified_client_id].to_i
      client_scope = IdentifiedClient.identified
    elsif params[:deidentified_client_id]
      client_id = params[:deidentified_client_id].to_i
      client_scope = DeidentifiedClient.deidentified
    else
      raise 'unroutable, should not be reached'
    end

    @non_hmis_client = client_scope.visible_to(current_user).find(client_id)
  end

  private def set_assessment
    @assessment = @non_hmis_client.non_hmis_assessments.find(params[:id].to_i)
  end

  private def set_neighborhoods
    @neighborhoods = Neighborhood.order(:name).pluck(:id, :name)
  end
end
