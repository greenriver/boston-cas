###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::MethProductionConviction < Rule
  def description
    'Matches clients who have been convicted of meth production as indicated on an assessment.'
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.meth_production_conviction missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:meth_production_conviction.to_s)

    scope.where(meth_production_conviction: requirement.positive)
  end
end
