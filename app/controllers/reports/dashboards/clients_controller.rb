###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Reports::Dashboards::ClientsController < ApplicationController
  include PjaxModalController

  before_action :require_can_view_reports!
  before_action :set_report

  def index
  end

  def client_details
    @section = client_details_sections.detect { |name| params[:section].to_sym == name }
    demographic = demographics_options.detect { |name| params[:by].to_sym == name }
    data = @report.public_send(@section, {by: demographic})
    return Client.none if data.nil?

    @key = data.keys.detect { |name| params[:key]== name } if params[:key].present?
    return Client.none if @key.nil?

    ids = data[@key].map { |client| client.id }
    @total_clients = ids.size
    @clients = Client.where(id: ids).
      visible_by(current_user).
      select(*client_details_columns)
  end

  def client_details_sections
    [
      :matched_clients,
      :successful_clients,
    ]
  end

  def client_details_columns
    [
      :id,
      :first_name,
      :last_name,
    ]
  end
  helper_method :client_details_columns

  def matches_details
    # start date, end date, client name, and link to the match
    demographic = demographics_options.detect { |name| params[:by].to_sym == name }
    @key = params[:key]
    @matches = @report.matches_for_clients(by: demographic, bucket: @key).
      pluck(*matches_details_columns.values).
      map do |row|
        matches_details_columns.values.zip(row).to_h
    end
  end

  def matches_details_columns
    {
      'Match ID' => :match_id,
      'First Name' => :first_name,
      'Last Name' => :last_name,
      'Started At' => :match_started_at,
      'Ended At' => :updated_at,
    }
  end
  helper_method :matches_details_columns

  def demographics_options
    [
      :gender,
    ]
  end

  def details_params
    {
      filter:
        {
          start_date: @start_date,
          end_date: @end_date,
          match_route: @match_route_id,
          program_types: @program_types,
        }
    }
  end
  helper_method :details_params

  def set_report
    @start_date = params.dig(:filter, :start_date)&.to_date || Date.current.last_year
    @end_date = params.dig(:filter, :end_date)&.to_date || Date.current
    @match_route_id = params.dig(:filter, :match_route) || MatchRoutes::Base.available.first.id
    @match_route_name = MatchRoutes::Base.find(@match_route_id.to_i).title

    @report = Dashboards::Clients.new(start_date: @start_date, end_date: @end_date, match_route_name: @match_route_name)
  end

end