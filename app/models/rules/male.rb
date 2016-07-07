class Rules::Male < Rule
  def clients_that_fit(scope, requirement)
    if gender = Client.arel_table[:gender_id]
      male = Gender.where(text: 'Male').pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: male)
      else
        scope.where.not(gender_id: male)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.gender_id missing. Cannot check clients against #{self.class}.")
    end
  end
end
