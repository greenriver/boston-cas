class Rules::Bedroom < Rule
  def variable_requirement?
    true
  end

  def available_number_of_bedrooms
    [
      [1, 'One'],
      [2, 'Two'],
      [3, 'Three'],
      [4, 'Four'],
      [5, 'Five'],
    ]
  end

  def display_for_variable(value)
    available_number_of_bedrooms.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:required_number_of_bedrooms.to_s)
      a_t = Client.arel_table
      if requirement.positive
        scope.where(a_t[:required_number_of_bedrooms].lteq(requirement.variable))
      else
        scope.where(a_t[:required_number_of_bedrooms].gt(requirement.variable))
      end
    else
      raise RuleDatabaseStructureMissing, "clients.required_number_of_bedrooms missing. Cannot check clients against #{self.class}."
    end
  end
end
