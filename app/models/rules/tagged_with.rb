###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::TaggedWith < Rule
  def description
    'Matches clients who have the specified tag.'
  end

  def variable_requirement?
    true
  end

  def variable_input_type
    'select'
  end

  def variable_label
    'Tag'
  end

  def variable_options
    available_tags
  end

  def available_tags
    Tag.all.map { |tag| [tag.id, tag.name] }
  end

  def display_for_variable value
    Tag.find_by(id: value)&.name || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.tags missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:tags.to_s)

    key = requirement.variable.to_s
    if requirement.positive
      scope.where('tags ->> ? is not null', key)
    else
      scope.where('not(tags ->> ? is not null) OR tags is null', key)
    end
  end
end
