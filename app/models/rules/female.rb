class Rules::Female < Rule
  def clients_that_fit(scope, requirement)
    if gender = Client.arel_table[:gender_id]
      female = Gender.where(text: 'Female').pluck(:numeric)
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
