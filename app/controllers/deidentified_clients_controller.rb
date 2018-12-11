class DeidentifiedClientsController < ApplicationController
  before_action :require_can_enter_deidentified_clients!
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update, :destroy]
  before_action :load_agencies

  def index
    # sort
    default_sort = 'days_homeless_in_the_last_three_years desc'
    sort_string = params[:q].try(:[], :s) || default_sort
    (@column, @direction) = sort_string.split(' ')
    @sorted_by = DeidentifiedClient.sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    # construct query
    @q = deidentified_client_source.ransack(params[:q])
    @deidentified_clients = @q.result(distinct: true)

    # filter
    if params[:agency].present?
      @deidentified_client = @deidentified_clients.where(agency: params[:agency])
    end
    if params[:cohort].present?
      @deidentified_clients = @deidentified_clients.where('active_cohort_ids @> ?', params[:cohort])
    end
    @active_filter = params[:agency].present? || params[:cohort].present?


    # paginate
    @page = params[:page].presence || 1
    @deidentified_clients = @deidentified_clients.reorder(sort_string).page(@page.to_i).per(25)
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

    def load_deidentified_client
      # since we sometimes arrive here looking for an identified client
      # attempt deidentified first, then shuffle them over to identified
      begin
        @deidentified_client = deidentified_client_source.find params[:id].to_i
      rescue
        redirect_to polymorphic_path([action_name, :identified_client], id: params[:id])
      end
    end

    def load_agencies
      @available_agencies = User.distinct.pluck(:agency).compact
    end
end
