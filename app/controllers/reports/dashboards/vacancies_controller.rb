###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Reports::Dashboards::VacanciesController < ApplicationController
  include PjaxModalController

  before_action :require_can_view_reports!
  before_action :set_report

  def index
  end

  def set_report
    @start_date = params.dig(:filter, :start_date)&.to_date || Date.current.last_year
    @end_date = params.dig(:filter, :end_date)&.to_date || Date.current
    @match_route_id = params.dig(:filter, :match_route) || MatchRoutes::Base.available.first.id
    @match_route_name = MatchRoutes::Base.find(@match_route_id.to_i).title
    @program_types = params.dig(:filter, :program_types)&.reject { |type| type.blank? } || []

    @report = Dashboards::Overview.new(start_date: @start_date, end_date: @end_date, match_route_name: @match_route_name, program_types: @program_types)
  end
end