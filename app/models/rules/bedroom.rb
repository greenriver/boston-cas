class Rules::Bedroom < Rule
  def variable_requirement?
    true
  end

  def available_number_of_bedrooms
    (1..5)
  end

  def display_for_variable value
    value
  end

  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:required_number_of_bedrooms.to_s)
      a_t = Client.arel_table
      if requirement.positive
        scope.where(required_number_of_bedrooms: requirement.variable)
      else
        scope.where.not(required_number_of_bedrooms: requirement.variable)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.required_number_of_bedrooms missing. Cannot check clients against #{self.class}.")
    end
  end
end
