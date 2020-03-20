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

  def details
  end

  def set_report
    @start_date = params.dig(:filter, :start_date)&.to_date || Date.current.last_year
    @end_date = params.dig(:filter, :end_date)&.to_date || Date.current
    @match_route_id = params.dig(:filter, :match_route) || MatchRoutes::Base.available.first.id
    @match_route_name = MatchRoutes::Base.find(@match_route_id.to_i).title

    @report = Dashboards::Clients.new(start_date: @start_date, end_date: @end_date, match_route_name: @match_route_name)
  end

end