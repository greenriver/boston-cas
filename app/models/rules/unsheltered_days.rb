###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::UnshelteredDays < Rule
  def variable_requirement?
    true
  end

  def available_unsheltered_days
    [
      [30, '30 Days'],
      [60, '60 Days'],
      [90, '90 Days'],
      [180, '180 Days'],
      [365, '365 Days'],
      [548, '548 Days'],
      [730, '730 Days'],
      [1095, '1095 Days'],
    ]
  end

  def display_for_variable value
    available_unsheltered_days.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    if Client.column_names.include?(:total_homeless_nights_unsheltered.to_s)
      if requirement.positive
        scope.where(c_t[:total_homeless_nights_unsheltered].gteq(requirement.variable))
      else
        scope.where(c_t[:total_homeless_nights_unsheltered].lt(requirement.variable))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.total_homeless_nights_unsheltered missing. Cannot check clients against #{self.class}.")
    end
  end
end
