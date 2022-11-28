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
    @in_progress ||= reporting_scope.
      in_progress
  end

  def match_statuses_json
    match_statuses.to_a.to_json.html_safe
  end

  def match_statuses
    reporting_scope.
      group(:current_status).
      count
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
    @total_unsuccessful_matches ||= reporting_scope.unsuccessful.count
  end

  private def combine_other_reasons(reason)
    return 'Other' if reason.starts_with?('Other: ')

    reason
  end

  def unsuccessful_match_reasons
    @unsuccessful_match_reasons ||= reporting_scope.
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
