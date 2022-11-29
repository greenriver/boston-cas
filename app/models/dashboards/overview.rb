###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::Overview < Dashboards::Base
  attr_accessor :filter

  def initialize(filter)
    @filter = filter
  end

  def in_progress
    @in_progress ||= reporting_scope.current_step.
      in_progress
  end

  def match_statuses
    reporting_scope.current_step.
      group(:current_status).
      count
  end

  def detail_info
    {
      terminal_status: {
        header: 'Terminal Status',
      },
      updated_at: {
        header: 'Date of Status',
      },
      program_name: {
        header: 'Program Name',
      },
      sub_program_name: {
        header: 'Sub Program Name',
      },
    }
  end

  def detail_headers
    detail_info.values.map { |v| v[:header] }
  end

  def detail_columns
    detail_info.keys
  end

  # Return format:
  # [
  #   ["Vacancy filled by other client", 2, 3, 4],
  #   ['Other reason', 1, 2, 3],
  # ]
  # Each column is the value for the quarter
  def match_statuses_by_quarter
    @match_statuses_by_quarter ||= {}.tap do |data|
      quarters_contained_in_report.values.map.with_index do |q_start, i|
        q_filter = @filter.class.new(@filter.to_h)
        q_filter.start = q_start
        q_filter.end = q_start.end_of_quarter
        Dashboards::Overview.new(q_filter).unsuccessful_match_reasons.each do |reason, count|
          data[reason] ||= []
          data[reason][i] = count
        end
      end
      data.each do |id, counts|
        data[id] = counts.map do |c|
          c.presence || 0
        end
      end
    end
  end

  # The unique unsuccessful reasons
  def quarter_chart_groups
    match_statuses_by_quarter.keys || []
  end

  def quarter_chart_data
    {
      columns: match_statuses_by_quarter.map { |k, v| [k] + v },
      type: 'bar',
      groups: [quarter_chart_groups],
      stack: { normalize: true },
    }
  end

  def quarter_chart_names
    quarters_contained_in_report.keys
  end

  def total_unsuccessful_matches
    @total_unsuccessful_matches ||= reporting_scope.current_step.unsuccessful.count
  end

  def reason_from_param(reason)
    return unless reason.present?

    unsuccessful_match_reasons.keys.detect { |r| r.downcase == reason.downcase }
  end

  private def combine_other_reasons(reason)
    return 'Other' if reason.starts_with?('Other: ')

    reason
  end

  # Return the average elapsed days between match_started_at and the current step
  # updated_at (for successful matches)
  def average_days_initiation_to_step_completion
    route = MatchRoutes::Base.where(id: @filter.match_routes).first
    active_steps = route.class.match_steps.keys
    reporting_decision_numbers = route.class.match_steps_for_reporting.select { |k, _| k.in?(active_steps) }.values
    reporting_scope.success.
      where(decision_order: reporting_decision_numbers).
      group([:decision_order, :match_step]).
      average(
        Arel::Nodes::Subtraction.new(
          r_d_t[:updated_at],
          r_d_t[:match_started_at],
        ),
      ).sort_by { |(decision_order, _), _| decision_order }
  end

  def unsuccessful_match_reasons
    @unsuccessful_match_reasons ||= reporting_scope.current_step.
      unsuccessful.
      has_a_reason.
      pluck(:decline_reason, :administrative_cancel_reason).
      map do |(decline, cancel)|
        combine_other_reasons(decline || cancel)
      end.
      tally
  end

  private def reporting_scope
    scope = Reporting::Decisions
    @filter.apply(scope)
  end
end
