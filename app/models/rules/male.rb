class Rules::Male < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:gender_id.to_s)
      male = Gender.where(numeric: [1, 3]).pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: male)
      else
        scope.where.not(gender_id: male)
      end
    else
      raise RuleDatabaseStructureMissing, "clients.gender_id missing. Cannot check clients against #{self.class}."
    end
  end
end
