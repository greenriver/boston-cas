class Rules::EnrolledInTh < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_in_th.to_s)
      scope.where(enrolled_in_th: requirement.positive)
    else
      raise RuleDatabaseStructureMissing.new("clients.enrolled_in_th missing. Cannot check clients against #{self.class}.")
    end
  end
end
