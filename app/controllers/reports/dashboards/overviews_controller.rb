###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Reports::Dashboards::OverviewsController < ApplicationController
  include PjaxModalController

  before_action :require_can_view_reports!
  before_action :set_report

  def index
  end

  def details
    @section = sections.detect { |name| params[:section].to_sym == name }
    data = @report.public_send(@section)
    return Client.none if data.nil?

    @key = data.keys.detect { |name| params[:key]== name } if params[:key].present?

    ids = if @key.present?
      @sub_key = data[@key].keys.detect { |name| params[:sub_key] == name } if params[:sub_key].present?
      if @sub_key.present?
        data[@key][@sub_key]
      else
        data[@key]
      end
    else
      data
    end

    @clients = Client.where(id: ids).select(*details_columns)
  end

  def sections
    [
      :in_progress,
      :match_results,
      :match_results_by_quarter,
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

  def details_columns
    [
      :id,
      :first_name,
      :last_name,
    ]
  end
  helper_method :details_columns

  def set_report
    @start_date = params.dig(:filter, :start_date)&.to_date || Date.current.last_year
    @end_date = params.dig(:filter, :end_date)&.to_date || Date.current
    @match_route_id = params.dig(:filter, :match_route) || MatchRoutes::Base.available.first.id
    @match_route_name = MatchRoutes::Base.find(@match_route_id.to_i).title
    @program_types = params.dig(:filter, :program_types)&.reject { |type| type.blank? } || []

    @report = Dashboards::Overview.new(start_date: @start_date, end_date: @end_date, match_route_name: @match_route_name, program_types: @program_types)
  end
end