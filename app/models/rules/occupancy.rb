###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::Occupancy < Rule
  def variable_requirement?
    true
  end

  def available_occupancy
    [
      [1, 'One'],
      [2, 'Two'],
      [3, 'Three'],
      [4, 'Four'],
      [5, 'Five'],
      [6, 'Six'],
      [7, 'Seven'],
      [8, 'Eight'],
      [9, 'Nine'],
      [10, 'Ten'],
    ]
  end

  def display_for_variable value
    available_occupancy.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, opportunity)
    if Client.column_names.include?(:required_minimum_occupancy.to_s)
      a_t = Client.arel_table
      if requirement.positive
        scope.where(a_t[:required_minimum_occupancy].lteq(requirement.variable))
      else
        scope.where(a_t[:required_minimum_occupancy].gt(requirement.variable))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.required_minimum_occupancy missing. Cannot check clients against #{self.class}.")
    end
  end
end
