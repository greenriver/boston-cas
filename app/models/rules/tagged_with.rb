###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Rules::TaggedWith < Rule
  def variable_requirement?
    true
  end

  def available_tags
    Tag.all.map{|tag| [tag.id, tag.name] }
  end

  def display_for_variable value
    Tag.find(value)&.name
  end

  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:tags.to_s)
      if requirement.positive
        where = "tags ->>'#{requirement.variable.to_s}' is not null"
      else
        where = "not(tags ->>'#{requirement.variable.to_s}' is not null) OR tags is null"
      end
      scope.where(where)
    else
      raise RuleDatabaseStructureMissing.new("clients.tags missing. Cannot check clients against #{self.class}.")
    end
  end
end
