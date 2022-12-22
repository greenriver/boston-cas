###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HasFileTags < Rule
  def variable_requirement?
    true
  end

  def available_tags
    return [] unless Warehouse::Base.enabled?

    Warehouse::Tag.pluck(:name).map do |name|
      [name, name] # The front end requires a map, so we construct one
    end.to_h
  end

  def display_for_variable(value)
    value_as_array(value).join(', ')
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.file_tags missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:file_tags.to_s)

    where = if requirement.positive
      'file_tags ?& array[:values]'
    else
      'NOT(file_tags ?& array[:values]) OR file_tags is null'
    end
    scope.where(where, values: value_as_array(requirement.variable))
  end

  private def value_as_array(value)
    value.split(',')
  end
end
