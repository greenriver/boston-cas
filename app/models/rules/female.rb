class Rules::Female < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:gender_id.to_s)
      female = Gender.where(numeric: [0,2,3]).pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: female)
      else
        scope.where.not(gender_id: female)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.gender_id missing. Cannot check clients against #{self.class}.")
    end
  end
end
