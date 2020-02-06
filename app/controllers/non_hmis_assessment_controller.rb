
class NonHmisAssessmentController < ApplicationController
  before_action :load_client, only: [:new, :show, :edit, :update, :index]

  def new
    @assessment = build_assessment
  end

  def index
    @assessment = load_assessment || @non_hmis_client.current_assessment
  end

  def show
    @assessment = load_assessment || @non_hmis_client.current_assessment
  end

  def create
    source = client_source.first
    @non_hmis_client = source.client_assessment.create(clean_params(client_params))
    respond_with(@non_hmis_client, location: redirect_path)
  end

  def update
    @non_hmis_client.client_assessment.update(clean_params(client_params))
    respond_with(@non_hmis_client, location: redirect_path)
  end

  def redirect_path
    if @non_hmis_client.identified?
      identified_clients_path
    elsif !@non_hmis_client.identified?
      deidentified_clients_path
    else
      imported_clients_path
    end
  end

  private
    def load_assessment
      NonHmisAssessment.find(params[:id].to_i) if params[:id]
    end

    def load_client
      client_id = nil
      client_id =
        if params.has_key?('deidentified_client_id')
          params[:deidentified_client_id]
        elsif params.has_key?('identified_client_id')
          params[:identified_client_id]
        elsif params.has_key?('imported_client_id')
          params[:imported_client_id]
        end
      (source, client_id) = client_source
      @non_hmis_client = source.find client_id.to_i
    end

    def client_source
      if params.has_key?('deidentified_client_id')
        [ DeidentifiedClient.deidentified.visible_to(current_user), params[:deidentified_client_id] ]
      elsif params.has_key?('identified_client_id')
        [ IdentifiedClient.identified.visible_to(current_user), params[:identified_client_id] ]
      elsif params.has_key?('imported_client_id')
        [ ImportedClient.imported.visible_to(current_user), params[:imported_client_id] ]
      end
    end

    def build_assessment
      assessment_type.constantize.new
    end

    def assessment_type
      if @non_hmis_client.identified?
        Config.get(:identified_client_assessment) || 'IdentifiedClientAssessment'
      elsif !@non_hmis_client.identified?
        Config.get(:deidentified_client_assessment) || 'DeidentifiedClientAssessment'
      else
        Config.get(:imported_client_assessment) || 'ImportedClientAssessment'
      end
    end

    def assessment_params
      params.require(:assessment).permit(
        :id,
        :type,
        :assessment_score,
        :vispdat_score,
        :vispdat_priority_score,
        :veteran,
        :actively_homeless,
        :days_homeless_in_the_last_three_years,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :family_member,
        :calculated_chronic_homelessness,
        :income_total_annual,
        :disabling_condition,
        :physical_disability,
        :developmental_disability,
        :domestic_violence,
        :interested_in_set_asides,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_wheelchair_accessibility,
        :requires_elevator_access,
        :youth_rrh_aggregate,
        :dv_rrh_aggregate,
        :veteran_rrh_desired,
        :rrh_th_desired,
        :sro_ok,
        :other_accessibility,
        :disabled_housing,
        neighborhood_interests: [],
      )
    end

    def clean_params
      assessment_params = {}

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

      assessment_params
    end
end
