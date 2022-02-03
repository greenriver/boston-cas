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
class Dashboards::Base
  def initialize(start_date:, end_date:, match_route_name:, program_types:)
    @start_date = start_date
    @end_date = end_date
    @match_route_name = match_route_name
    @program_types = program_types
  end


  def quarters_in_report
    # Find first quarter in year that is also in reporting period
    quarter = @start_date.beginning_of_quarter
    q_num = quarter_number(@start_date) # zero-based

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

  private def quarter_number(date)
    quarter = date.beginning_of_quarter
    start_month = date.month
    (start_month / 3.0).ceil - 1
  end
end
