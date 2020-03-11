###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###
#
class Dashboards::Overview
  def initialize(start_date:, end_date:, match_route_name:, program_types:)
    @start_date = start_date
    @end_date = end_date
    @match_route_name = match_route_name
    @program_types = program_types
  end

  def in_progress
    @in_progress ||= reporting_scope.
      in_progress.
      distinct.
      pluck(:cas_client_id)
  end

  def terminated(start_date: @start_date, end_date: @end_date)
    reporting_scope.
      ended_between(start_date: start_date, end_date: end_date).
      distinct.
      pluck(:terminal_status, :cas_client_id)
  end

  def match_results(start_date: @start_date, end_date: @end_date)
    hash = terminated(start_date: start_date, end_date: end_date).group_by(&:first)
    hash.merge(hash) { |key, ids| ids.map { |key, id| id }}
  end

  def match_results_by_quarter
    quarters_in_report.map do |quarter, start_date|
      [quarter, match_results(start_date: start_date, end_date: start_date.next_quarter - 1.day)]
    end.to_h
  end

  def preempted_decline_reasons
    reasons = reporting_scope.
      preempted.
      where.not(decline_reason: nil)

    total = reasons.count
    reasons.group(:decline_reason).
      order(count: :desc).
      count.
      map { |reason, count| { label: reason, count: count, percent: count * 100 / total } }
  end

  def preempted_cancel_reasons
    reasons = reporting_scope.
      preempted.
      where.not(administrative_cancel_reason: nil)

    total = reasons.count
    reasons.group(:administrative_cancel_reason).
      order(count: :desc).
      count.
      map { |reason, count| { label: reason, count: count, percent: count * 100 / total } }
  end

  def rejected_decline_reasons
    reasons = reporting_scope.
      rejected.
      where.not(decline_reason: nil)

    total = reasons.count
    reasons.group(:decline_reason).
      order(count: :desc).
      count.
      map { |reason, count| { label: reason, count: count, percent: count * 100 / total } }
  end

  def quarters_in_report
    # Find first quarter in year that is also in reporting period
    quarter = @start_date.beginning_of_year
    q_num = 0
    until (quarter..quarter.next_quarter).cover?(@start_date)
      quarter = quarter.next_quarter
      q_num += 1
    end

    # Enumerate quarters that are in the reporting period
    quarters = {}
    until quarter > @end_date
      quarter_label = "#{quarter.year}.#{(q_num % 4) + 1}"
      quarters[quarter_label] = quarter

      quarter = quarter.next_quarter
      q_num += 1
    end
    quarters
  end

  def reporting_scope
    scope = Reporting::Decisions.
      started_between(start_date: @start_date, end_date: @end_date).
      where(match_route: @match_route_name)
    if @program_types.present?
      scope.where(program_type: @program_types)
    else
      scope
    end
  end
end