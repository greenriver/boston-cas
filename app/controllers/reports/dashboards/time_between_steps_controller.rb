###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Reports::Dashboards::TimeBetweenStepsController < ApplicationController
  before_action :require_can_view_reports!
  before_action :set_report, only: [:index]

  def index
  end

  def step_name_options
    match_route_id = params[:match_route].to_i || MatchRoutes::Base.available.first.id
    @step_names = step_names(match_route_id)
    keys = @step_names.keys
    if params[:group] == 'from'
      @selected = @step_names[keys.first]
    else
      @selected = @step_names[keys.last]
    end
    render layout: false
  end

  def step_names(match_route_id)
    match_steps = MatchRoutes::Base.find(match_route_id).class.match_steps
    match_steps.map { |match_step, order| [match_step.constantize.new.step_name, order] }.to_h
  end

  def set_report
    @start_date = params.dig(:filter, :start_date)&.to_date || Date.current.last_year
    @end_date = params.dig(:filter, :end_date)&.to_date || Date.current
    @match_route_id = params.dig(:filter, :match_route) || MatchRoutes::Base.available.first.id
    @match_route_name = MatchRoutes::Base.find(@match_route_id.to_i).title
    @program_types = params.dig(:filter, :program_types)&.reject { |type| type.blank? } || []
    @step_names = step_names(@match_route_id.to_i)
    keys = @step_names.keys
    @from_step = @step_names[keys.first]
    @to_step = @step_names[keys.last]

    # TODO @report =
  end
end