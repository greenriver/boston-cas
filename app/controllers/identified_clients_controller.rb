class IdentifiedClientsController < NonHmisClientsController
  before_action :require_can_enter_identified_clients!
  before_action :require_can_manage_identified_clients!, only: [:edit, :update, :destroy]

  def create
    @non_hmis_client = client_source.create(clean_params(identified_client_params))
    respond_with(@non_hmis_client, location: identified_clients_path)
  end

  def update
    @non_hmis_client.update(clean_params(identified_client_params))
    respond_with(@non_hmis_client, location: identified_clients_path)
  end

  def destroy
    @non_hmis_client.destroy
    respond_with(@non_hmis_client, location: identified_clients_path)
  end

  def clean_params dirty_params
    dirty_params[:active_cohort_ids] = dirty_params[:active_cohort_ids]&.reject(&:blank?)&.map(&:to_i)
    dirty_params[:active_cohort_ids] = nil if dirty_params[:active_cohort_ids].blank?
    return dirty_params
  end

  def sort_options
    [
        {title: 'Last Name A-Z', column: 'last_name', direction: 'asc', order: 'LOWER(last_name) ASC', visible: true},
        {title: 'Last Name Z-A', column: 'last_name', direction: 'desc', order: 'LOWER(last_name) DESC', visible: true},
        {title: 'Age', column: 'date_of_birth', direction: 'asc', order: 'date_of_birth ASC', visible: true},
        {title: 'Assessment Score', column: 'assessment_score', direction: 'desc', order: 'assessment_score DESC', visible: true},
        {title: 'Days Homeless in the Last 3 Years', column: 'days_homeless_in_the_last_three_years', direction: 'desc',
            order: 'days_homeless_in_the_last_three_years DESC', visible: true},
    ]
  end
  helper_method :sort_options

  def filter_terms
    [ :agency, :cohort, :family_member, :available ]
  end
  helper_method :filter_terms

  private

    def client_source
      IdentifiedClient.identified.visible_to(current_user)
    end

    def identified_client_params
      params.require(:identified_client).permit(
        :client_identifier,
        :assessment_score,
        :agency,
        :first_name,
        :last_name,
        :middle_name,
        :date_of_birth,
        :ssn,
        :days_homeless_in_the_last_three_years,
        :date_days_homeless_verified,
        :who_verified_days_homeless,
        :veteran,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :full_release_on_file,
        :requires_wheelchair_accessibility,
        :required_number_of_bedrooms,
        :required_minimum_occupancy,
        :requires_elevator_access,
        :family_member,
        :calculated_chronic_homelessness,
        :gender,
        :available,
        :active_cohort_ids => [],
      ).merge(identified: true)
    end
end
