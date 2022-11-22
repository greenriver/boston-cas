###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Dashboards::Base
  def section_name(name)
    self.class.section_names[name]
  end

  def section_ids
    self.class.section_names.values
  end

  def self.section_names
    @section_names ||= {
      'In Progress' => :working,
      'Stalled' => :stalled,
      'Success' => :success,
      'Pre-empted' => :preempted,
      'Rejected' => :rejected,
      'Declined' => :declined,

      'in_progress' => :in_progress,
      'unsuccessful' => :unsuccessful,
    }
  end

  # Query functions for sections, turns the section keys into scope names
  section_names.values.each do |status|
    define_method(status.to_s) do
      reporting_scope.
        public_send(status)
    end
  end

  def quarters_in_report
    # Find first quarter in year that is also in reporting period
    quarter = @filter.start.beginning_of_quarter
    q_num = quarter_number(@filter.start) # zero-based

    # Enumerate quarters that are in the reporting period
    quarters = {}
    until quarter > @filter.end
      quarter_label = "#{quarter.year}.#{(q_num % 4) + 1}"
      quarters[quarter_label] = quarter

      quarter = quarter.next_quarter
      q_num += 1
    end
    quarters
  end

  private def quarter_number(date)
    start_month = date.month
    (start_month / 3.0).ceil - 1
  end
end
