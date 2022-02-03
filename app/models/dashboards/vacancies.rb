###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Dashboards::Vacancies < Dashboards::Base
  include ArelHelper

  def initialize(start_date:, end_date:, match_route_name:, program_types:)
    @start_date = start_date
    @end_date = end_date
    @match_route_name = match_route_name
    @program_types = program_types
  end

  def in_progress
    @in_progress ||= reporting_scope.
      merge(Reporting::Decisions.in_progress).
      distinct.
      pluck(r_d_t[:cas_client_id]).
      map do |id|
        { id: id }
      end
  end

  def vacancy_results
    hash = reporting_scope.
      merge(Reporting::Decisions.terminated).
      distinct.
      pluck(r_d_t[:terminal_status], :cas_client_id).group_by(&:first)
    hash.merge(hash) do |_key, ids|
      ids.map do |_status, id|
        { id: id }
      end
    end
  end

  def vacancies_filled(start_date:, end_date:)
    hash = reporting_scope.
      merge(Reporting::Decisions.success.current_step.ended_between(start_date: start_date, end_date: end_date)).
      distinct.
      pluck(r_d_t[:program_type], :cas_client_id, :created_at, r_d_t[:updated_at], r_d_t[:client_move_in_date]).group_by(&:first)
    hash.merge(hash) do |_key, ids|
      ids.map do |program_type, id, created_at, decision_updated_at, move_in_date|
        occupied_at = move_in_date || decision_updated_at
        {
          id: id,
          days_to_success: (occupied_at.to_date - created_at.to_date).to_i
        }
      end
    end
  end

  def vacancies_filled_by_quarter
    @vacancies_filled_by_quarter ||= quarters_in_report.map do |quarter, start_date|
      range = start_date.all_quarter
      [quarter, vacancies_filled(start_date: range.first, end_date: range.last)]
    end.to_h
  end

  def average_days
    filled = vacancies_filled(start_date: @start_date, end_date: @end_date)
    sum = 0
    filled.keys.each do |project_type|
      sum += filled[project_type].sum { |datum| datum[:days_to_success] }
    end
    if filled.present?
      sum / filled.count
    else
      'N/A'
    end
  end

  def reporting_scope
    scope = Opportunity.
      joins(:reporting_decisions).
      merge(Reporting::Decisions.
        started_between(start_date: @start_date, end_date: @end_date).
        where(match_route: @match_route_name))
    if @program_types.present?
      scope.where(r_d_t[:program_type].in(@program_types))
    else
      scope
    end
  end
end
