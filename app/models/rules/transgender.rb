class Rules::Transgender < Rule
  def clients_that_fit(scope, requirement)
    if gender = Client.arel_table[:gender_id]
      gender_arel = Gender.arel_table
      transgender = Gender.where(gender_arel[:text].matches('Transgender%')).distinct.pluck(:numeric)
      if requirement.positive
        scope.where(gender_id: transgender)
      else
        scope.where.not(gender_id: transgender)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.gender_id missing. Cannot check clients against #{self.class}.")
    end
  end
end
