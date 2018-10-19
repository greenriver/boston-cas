class DeidentifiedClientsController < ApplicationController
  before_action :require_can_enter_deidentified_clients!
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update, :destroy]
  before_action :load_agencies, only: [:new, :edit]

  def index
    @deidentified_clients = deidentified_client_source.order(agency: :asc, last_name: :asc, first_name: :asc).page(params[:page]).per(25)
  end

  def create
    @deidentified_client = deidentified_client_source.create(clean_params(deidentified_client_params))
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end

  def new
    @deidentified_client = deidentified_client_source.new(agency: current_user.agency)
  end

  def edit
  end

  def update
    @deidentified_client.update(clean_params(deidentified_client_params))
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end

  def destroy
    @deidentified_client.destroy
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end

  def deidentified_client_source
    DeidentifiedClient.deidentified.visible_to(current_user)
  end

  private
    def deidentified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier,
        :assessment_score,
        :agency,
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

    def load_deidentified_client
      @deidentified_client = deidentified_client_source.find params[:id].to_i
    end

    def load_agencies
      @available_agencies = User.distinct.pluck(:agency).compact
    end
end
