###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Rules::TaggedWith < Rule
  def description
    'Matches clients who have the specified tag.'
  end

  def variable_requirement?
    true
  end

  def available_tags
    Tag.all.map { |tag| [tag.id, tag.name] }
  end

  def display_for_variable value
    Tag.find(value)&.name
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.tags missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:tags.to_s)

    if requirement.positive
      where = "tags ->>'#{requirement.variable}' is not null"
    else
      where = "not(tags ->>'#{requirement.variable}' is not null) OR tags is null"
    end
    scope.where(where)
  end
end
