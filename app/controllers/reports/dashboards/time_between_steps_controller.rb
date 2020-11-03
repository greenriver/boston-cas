###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Reports::Dashboards::TimeBetweenStepsController < ApplicationController
  include AjaxModalRails::Controller

  before_action :require_can_view_reports!
  before_action :set_report, except: [:step_name_options]

  def index
  end


  def details
    ids = @report.time_between_steps[params[:bucket]]
    @total_matches = ids.size
    @matches = ClientOpportunityMatch.where(id: ids).
      visible_by(current_user)
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

  def step_names(match_route_id)
    match_steps = MatchRoutes::Base.find(match_route_id).class.match_steps_for_reporting
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
    @from_step = params.dig(:filter, :from_step)&.to_i || @step_names[keys.first]
    @to_step = params.dig(:filter, :to_step)&.to_i || @step_names[keys.last]

    # Move from step back one if it is the last step
    @from_step -= 1 if @from_step == @step_names[keys.last]
    # Move the to step forward to the from step if it is before
    @to_step = @from_step if @to_step < @from_step
    # Move the to step forward one if it is the same as the last step
    @to_step += 1 if @to_step == @from_step

    @report = Dashboards::TimeBetweenSteps.new(
      start_date: @start_date,
      end_date: @end_date,
      match_route_name: @match_route_name,
      program_types: @program_types,
      from_step: @from_step,
      to_step: @to_step,
    )
  end
end
