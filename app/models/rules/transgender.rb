class Rules::Transgender < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:gender_id.to_s)
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
