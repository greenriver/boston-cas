class DeidentifiedClientsController < NonHmisClientsController
  before_action :require_can_enter_deidentified_clients!
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]

  def create
    @non_hmis_client = client_source.create(clean_params(deidentified_client_params))
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def update
    @non_hmis_client.update(clean_params(deidentified_client_params))
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def destroy
    @non_hmis_client.destroy
    respond_with(@non_hmis_client, location: deidentified_clients_path)
  end

  def client_source
    DeidentifiedClient.deidentified.visible_to(current_user)
  end

  def sort_options
    [
        {title: 'Client Identifier A-Z', column: 'client_identifier', direction: 'asc', query: 'LOWER(client_identifier) ASC', visible: true},
        {title: 'Client Identifier Z-A', column: 'client_identifier', direction: 'desc', query: 'LOWER(client_identifier) DESC', visible: true},
        {title: 'Assessment Score', column: 'assessment_score', direction: 'desc', query: 'assessment_score DESC', visible: true},
        {title: 'Days Homeless in the Last 3 Years', column: 'days_homeless_in_the_last_three_years', direction: 'desc',
            query: 'days_homeless_in_the_last_three_years DESC', visible: true},
    ]
  end
  helper_method :sort_options

  def filter_terms
    [ :agency, :cohort ]
  end
  helper_method :filter_terms

  private
    def deidentified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier,
        :assessment_score,
        :agency,
        :date_of_birth,
        :ssn,
        :days_homeless_in_the_last_three_years,
        :veteran,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :family_member,
        :calculated_chronic_homelessness,
        :gender,
        :active_cohort_ids => [],
      ).merge(identified: false)
    end

    def append_client_identifier dirty_params
      dirty_params[:last_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      dirty_params[:first_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      return dirty_params
    end

    def clean_params dirty_params
      dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
      dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?
      return append_client_identifier(dirty_params)
    end
end
