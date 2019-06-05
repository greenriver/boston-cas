###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::AidsOrRelatedDiseases < Rule
  def clients_that_fit(scope, requirement)
    c_t = Client.arel_table
    if hiv_aids = Client.column_names.include?(:hiv_aids.to_s) && Client.column_names.include?(:hiv_positive.to_s)
      if requirement.positive
        scope.where(c_t[:hiv_aids].eq(true).or(c_t[:hiv_positive].eq(true)))
      else
        scope.where(c_t[:hiv_aids].eq(false).and(c_t[:hiv_positive].eq(false)))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.hiv_aids missing. Cannot check clients against #{self.class}.")
    end
  end
end
