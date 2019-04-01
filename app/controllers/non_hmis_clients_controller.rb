require 'xlsxtream'
class NonHmisClientsController < ApplicationController
  before_action :load_client, only: [:edit, :update, :destroy]
  before_action :load_agencies
  before_action :load_neighborhoods
  before_action :set_active_filter, only: [:index]

  helper_method :client_type

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
    if clean_agency.present?
      @non_hmis_clients = @non_hmis_clients.where(agency: clean_agency)
    end
    if clean_cohort.present?
      @non_hmis_clients = @non_hmis_clients.where('active_cohort_ids @> ?', clean_cohort)
    end
    if clean_available.present?
      @non_hmis_clients = @non_hmis_clients.where(available: clean_available)
    end
    if clean_family_member.present?
      @non_hmis_clients = @non_hmis_clients.family_member(clean_family_member)
    end
    respond_to do |format|
      format.html do
        # paginate
        @page = params[:page].presence || 1
        @non_hmis_clients = @non_hmis_clients.reorder(sort_order).page(@page.to_i).per(25)
      end
      format.xlsx do
        download
      end
    end
  end

  def download
    io = StringIO.new
    xlsx = Xlsxtream::Workbook.new(io)
    xlsx.write_worksheet client_type do |sheet|
      sheet << client_source.new.download_headers
      @non_hmis_clients.each do |client|
        sheet << client.download_data
      end
    end
    xlsx.close
    send_data io.string,
              filename: "#{client_type}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
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
    sort_string
  end

  def load_client
    # since we sometimes arrive here looking for an identified client
    # attempt deidentified first, then shuffle them over to identified

    @non_hmis_client = client_source.find params[:id].to_i
  rescue StandardError
    redirect_to polymorphic_path([action_name, :identified_client], id: params[:id])
  end

  def load_agencies
    @available_agencies = User.distinct.pluck(:agency).compact
  end

  def load_neighborhoods
    @neighborhoods = Neighborhood.order(:name).pluck(:id, :name)
  end

  def set_active_filter
    @active_filter = filter_terms.map { |k| params[k].present? }.any?
  end

  def clean_agency
    NonHmisClient.possible_agencies.detect { |m| m.downcase == params[:agency]&.downcase }
  end

  def clean_cohort
    NonHmisClient.possible_cohorts.keys.detect { |m| m.to_i == params[:cohort]&.to_i }.to_s
  end

  def clean_available
    [true, false].detect { |m| m.to_s == params[:available] }
  end

  def clean_family_member
    [true, false].detect { |m| m.to_s == params[:family_member] }
  end
end
