###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NonHmisAssessmentsController < ApplicationController
  before_action :set_client
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]
  before_action :require_can_see_assessment!, only: [:show]
  before_action :require_can_edit_assessment!, only: [:edit, :update, :destroy]
  before_action :set_neighborhoods

  def index
    @assessments = NonHmisAssessment.where(non_hmis_client_id: @non_hmis_client.id)
  end

  def new
    @assessment = build_assessment
  end

  def create
    @assessment = build_assessment
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

  private def clean_assessment_params(assessment_params)
    if assessment_params[:income_total_annual].present?
      assessment_params[:income_total_monthly] = assessment_params[:income_total_annual].to_i / 12
    end

    if assessment_params.key?(:youth_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:youth_rrh_aggregate].in?(['adult', 'both'])
      assessment_params[:youth_rrh_desired] = true if assessment_params[:youth_rrh_aggregate].in?(['youth', 'both'])
      assessment_params.extract![:youth_rrh_aggregate]
    end

    if assessment_params.key?(:dv_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:dv_rrh_aggregate].in?(['non-dv', 'both'])
      assessment_params[:dv_rrh_desired] = true if assessment_params[:dv_rrh_aggregate].in?(['dv', 'both'])
      assessment_params.extract![:dv_rrh_aggregate]
    end

    if assessment_params[:neighborhood_interests].present?
      assessment_params[:neighborhood_interests] = assessment_params[:neighborhood_interests]&.reject(&:blank?)&.map(&:to_i)
    end

    # Cleanup Vouchers; for now, just check for the word voucher in the response to 3E
    assessment_params[:have_tenant_voucher] = assessment_params[:pending_housing_placement_type]&.downcase&.include?('voucher')

    assessment_params[:user_id] = current_user.id

    assessment_params[:required_number_of_bedrooms] = nil if assessment_params[:required_number_of_bedrooms] == 'on'
    assessment_params[:sro_ok] = nil if assessment_params[:sro_ok] == 'on'

    assessment_params
  end

  private def require_can_edit_assessment!
    not_authorized! unless @assessment.editable_by?(current_user)
  end

  private def require_can_see_assessment!
    not_authorized! unless @assessment.viewable_by?(current_user)
  end

  private def build_assessment
    assessment = @non_hmis_client.assessment_type.constantize.new(agency_id: current_user.agency_id, non_hmis_client_id: @non_hmis_client.id)
    return assessment unless assessment.requires_assessment_type_choice? && assessment.assessment_type.blank? && params[:assessment_type].present?

    assessment.assessment_type = params[:assessment_type]
    assessment
  end

  private def set_client
    client_id = (params[:identified_client_id] || params[:deidentified_client_id]).to_i
    @non_hmis_client = NonHmisClient.visible_to(current_user).find(client_id)
  end

  private def set_assessment
    @assessment = NonHmisAssessment.visible_by(current_user).find(params[:id].to_i)
  end

  private def set_neighborhoods
    @neighborhoods = Neighborhood.order(:name).pluck(:id, :name)
  end
end
