###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::Base
  include ArelHelper
  def section_name(name)
    self.class.section_names[name]
  end

  def section_ids
    self.class.section_names.values
  end

  def self.section_names
    @section_names ||= {
      'In Progress' => :ongoing_not_stalled,
      'Stalled' => :stalled,
      'Success' => :success,
      'Pre-empted' => :preempted,
      'Rejected' => :rejected,
      'Declined' => :declined,
      'Expired' => :expired,
      'In Progress or Stalled' => :in_progress,
      'Unsuccessful' => :unsuccessful,
    }
  end

  def human_readable_section_name(section)
    self.class.section_names.invert[section.to_sym]
  end

  # Query functions for sections, turns the section keys into scope names
  section_names.values.each do |status|
    define_method(status.to_s) do
      reporting_scope.current_step.
        public_send(status)
    end
  end

  def show_quarters?
    longitudinal_dates.count > 1
  end

  def longitudinal_dates
    @longitudinal_dates ||= [].tap do |dates|
      end_quarter = @filter.end
      start_quarter = end_quarter - 3.months
      while start_quarter >= @filter.start
        dates << [start_quarter, end_quarter]
        end_quarter = start_quarter - 1.days
        start_quarter = end_quarter - 3.months
      end
    end
  end

  # Returns a hash of Quarter name and start date of the quarter for
  # quarters that are completely contained within the reporting period
  def quarters_contained_in_report
    # Find first quarter in year that is also in reporting period
    quarter = @filter.start.beginning_of_quarter
    q_num = quarter_number(@filter.start) # zero-based

    # Enumerate quarters that are in the reporting period
    quarters = {}
    until quarter > @filter.end
      quarter_label = "#{quarter.year} Q#{(q_num % 4) + 1}"
      quarters[quarter_label] = quarter

      quarter = quarter.next_quarter
      q_num += 1
    end
    quarters.select do |_, q_start|
      q_start > @filter.start && q_start.end_of_quarter <= @filter.end
    end
  end

  private def quarter_number(date)
    start_month = date.month
    (start_month / 3.0).ceil - 1
  end
end
