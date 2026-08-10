###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::RankBelow < Rule
  def description
    'Matches clients whose rank on cohorts is below the specified value.'
  end

  def variable_requirement?
    true
  end

  def variable_input_type
    'select'
  end

  def variable_label
    'Rank'
  end

  def variable_options
    available_ranks
  end

  def available_ranks
    (1..500)
  end

  def display_for_variable value
    value.to_i
  end

  def clients_that_fit(scope, requirement, opportunity)
    return scope unless opportunity

    raise RuleDatabaseStructureMissing.new("clients.tags missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:tags.to_s)

    tag_id = opportunity.match_route.tag_id
    return scope unless tag_id

    if requirement.positive
      scope.where(Arel.sql("(tags->>'#{tag_id.to_i}')::int < #{requirement.variable}"))
    else
      scope.where(Arel.sql("(tags->>'#{tag_id.to_i}')::int >= #{requirement.variable}"))
    end
  end
end
