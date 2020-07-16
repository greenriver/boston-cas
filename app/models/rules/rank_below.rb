###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::RankBelow < Rule
  def variable_requirement?
    true
  end

  def available_ranks
    (1..500)
  end

  def display_for_variable value
    value.to_i
  end

  def clients_that_fit(scope, requirement, opportunity)
    return scope unless opportunity

    if Client.column_names.include?(:tags.to_s)
      tag_id = opportunity.match_route.tag_id
      return scope unless tag_id

      if requirement.positive
        scope.where(Arel.sql("(tags->>'#{tag_id.to_i}')::int < #{requirement.variable}"))
      else
        scope.where(Arel.sql("(tags->>'#{tag_id.to_i}')::int >= #{requirement.variable}"))
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.tags missing. Cannot check clients against #{self.class}.")
    end
  end
end
