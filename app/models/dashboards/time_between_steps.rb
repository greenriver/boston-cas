###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::TimeBetweenSteps < Dashboards::Base
  include ArelHelper

  def initialize(start_date:, end_date:, match_route_name:, program_types:, from_step:, to_step:)
    super(start_date: start_date, end_date: end_date, match_route_name: match_route_name, program_types: program_types)
    @from_step = from_step
    @to_step = to_step
  end

  def average
    sums = reporting_scope
    return 0 if sums.size.zero?

    (sums.values.sum / Float(sums.size)).round
  end

  def time_between_steps
    answers = {}
    sums = reporting_scope
    buckets.each do |label, range|
      answers[label] = sums.select { |_id, days| range.include?(days) }.keys
    end
    answers
  end

  def buckets
    {
      'Less than 1 week' => 0..6,
      '1 week - 1 month' => 7..30,
      '1 month - 3 months' => 31..90,
      '3 months - 6 months' => 91..180,
      'More than 6 months' => 181..Float::INFINITY,
    }
  end

  def reporting_scope
    scope = Reporting::Decisions.
      started_between(start_date: @start_date, end_date: @end_date).
      where(match_route: @match_route_name)
    scope = scope.where(program_type: @program_types) if @program_types.present?

    scope.where(decision_order: @from_step..@to_step).
      group(:match_id).
      sum(:elapsed_days)
  end
end
