class IdentifiedClientsController < DeidentifiedClientsController
  before_action :require_can_enter_deidentified_clients!
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update]

  def create
    @deidentified_client = deidentified_client_source.create identified_client_params
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end

  def new
    @deidentified_client = deidentified_client_source.new
  end

  def edit
  end

  def update
    @deidentified_client.update(identified_client_params)
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end

  private
    def identified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier,
        :assessment_score,
        :agency,
        :first_name,
        :last_name,
        :dob,
        :ssn,
        :days_homeless_in_the_last_three_years,
        :veteran,
        :rrh_desired,
        :youth_rrh_desired,
        :rrh_assessment_contact_info,
        :income_maximization_assistance_requested,
        :pending_subsidized_housing_placement,
        :active_cohort_ids => [],
      ).merge(identified: true)
    end
end
