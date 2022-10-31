###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::Overview < Dashboards::Base
  def initialize(filter)
    @filter = filter
  end

  def in_progress
    @in_progress ||= reporting_scope.
      in_progress.
      distinct.
      pluck(:cas_client_id)
  end

  def terminated(range = @filter.range)
    reporting_scope.
      ended_between(range).
      distinct.
      pluck(:terminal_status, :cas_client_id)
  end

  def match_results(range)
    terminated(range).
      group_by(&:shift).
      transform_values(&:flatten)
  end

  def match_results_by_quarter
    quarters_in_report.map do |quarter, start_date|
      range = start_date.all_quarter
      [quarter, match_results(range)]
    end.to_h
  end

  def total_unsuccessful_matches
    @total_unsuccessful_matches ||= reporting_scope.unsuccessful.has_a_reason.count
  end

  def unsuccessful_match_reasons
    @unsuccessful_match_reasons ||= reporting_scope.
      unsuccessful.
      has_a_reason.
      pluck(:decline_reason, :administrative_cancel_reason, :match_step, :actor_type).
      map do |(decline, cancel, step_name, actor_type)|
        {
          reason: decline || cancel,
          step_name: step_name,
          actor_type: actor_type,
        }
      end
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

  def reporting_scope
    scope = Reporting::Decisions
    @filter.apply(scope)
  end
end
