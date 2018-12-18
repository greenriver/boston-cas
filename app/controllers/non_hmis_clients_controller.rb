class NonHmisClientsController < ApplicationController
  before_action :load_client, only: [:edit, :update, :destroy]
  before_action :load_agencies

  def index
    # sort
    sort_order = sorter
    @sorted_by = sort_options.select do |m|
      m[:column] == @column && m[:direction] == @direction
    end.first[:title]

    # construct query
    @q = client_source.ransack(params[:q])
    @non_hmis_clients = @q.result(distinct: false)

    # filter
    if params[:agency].present?
      @non_hmis_client = @non_hmis_clients.where(agency: params[:agency])
    end
    if params[:cohort].present?
      @non_hmis_clients = @non_hmis_clients.where('active_cohort_ids @> ?', params[:cohort])
    end
    if params[:family_member].present?
      if params[:family_member] == 'true'
        @non_hmis_clients = @non_hmis_clients.family_member(true)
      else
        @non_hmis_clients = @non_hmis_clients.family_member(false)
      end
    end
    @active_filter = params[:agency].present? || params[:cohort].present? || params[:family_member].present?


    # paginate
    @page = params[:page].presence || 1
    @non_hmis_clients = @non_hmis_clients.reorder(sort_order).page(@page.to_i).per(25)
  end

  def new
    @non_hmis_client = client_source.new(agency: current_user.agency)
  end

  def edit
  end

  def sorter
    @column = params[:sort]
    @direction = params[:direction]

    if @column.blank?
      @column = 'days_homeless_in_the_last_three_years'
      @direction = 'desc'
      sort_string = "#{@column} #{@direction}"
    else
      sort_string = sort_options.select do |m|
        m[:column] == @column && m[:direction] == @direction
      end.first[:order]
    end

    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      sort_string += ' NULLS LAST'
    end
    return sort_string
  end

  def load_client
    # since we sometimes arrive here looking for an identified client
    # attempt deidentified first, then shuffle them over to identified
    begin
      @non_hmis_client = client_source.find params[:id].to_i
    rescue
      redirect_to polymorphic_path([action_name, :identified_client], id: params[:id])
    end
  end

  def load_agencies
    @available_agencies = User.distinct.pluck(:agency).compact
  end

end