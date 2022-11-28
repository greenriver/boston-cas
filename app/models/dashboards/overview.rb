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

  def reasons_json
    unsuccessful_match_reasons.to_a.to_json.html_safe
  end

  def match_statuses
    reporting_scope.
      group(:current_status).
      count
  end

  def total_unsuccessful_matches
    @total_unsuccessful_matches ||= reporting_scope.unsuccessful.count
  end

  private def combine_other_reasons(reason)
    return 'Other' if reason.starts_with?('Other: ')

    reason
  end

  private def unsuccessful_match_reasons
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
