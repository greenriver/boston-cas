
class NonHmisAssessmentController < ApplicationController

  def new
    @assessment = build_assessment
  end

  def index
    # @assessment = load_assessment || @non_hmis_client.current_assessment
  end

  def show
    @assessment = load_assessment || @non_hmis_client.current_assessment
  end

  def load_assessment
    NonHmisAssessment.find(params[:assessment_id].to_i) if params[:assessment_id]
  end

  def build_assessment
    assessment_type.constantize.new
  end

  def assessment_type
    Config.get(:identified_client_assessment) || 'IdentifiedClientAssessment'
  end

  def clean_assessment_params dirty_params
    assessment_params = dirty_params.dig(:client_assessments_attributes, '0')
    return dirty_params unless assessment_params.present?

    assessment_params[:type] = assessment_type

    if assessment_params[:income_total_annual].present?
      assessment_params[:income_total_monthly] = assessment_params[:income_total_annual].to_i / 12
    end

    if assessment_params.has_key?(:youth_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:youth_rrh_aggregate] == 'adult' || assessment_params[:youth_rrh_aggregate] == 'both'
      assessment_params[:youth_rrh_desired] = true if assessment_params[:youth_rrh_aggregate] == 'youth' || assessment_params[:youth_rrh_aggregate] == 'both'
      assessment_params.extract![:youth_rrh_aggregate]
    end
    if assessment_params.has_key?(:dv_rrh_aggregate)
      assessment_params[:rrh_desired] = true if assessment_params[:dv_rrh_aggregate] == 'dv' || assessment_params[:dv_rrh_aggregate] == 'both'
      assessment_params[:dv_rrh_desired] = true if assessment_params[:dv_rrh_aggregate] == 'non-dv' || assessment_params[:dv_rrh_aggregate] == 'both'
      assessment_params.extract![:dv_rrh_aggregate]
    end

    if assessment_params[:neighborhood_interests].present?
      assessment_params[:neighborhood_interests] = assessment_params[:neighborhood_interests]&.reject(&:blank?)&.map(&:to_i)
    end

    assessment_params[:user_id] = current_user.id

    return dirty_params
  end
end
