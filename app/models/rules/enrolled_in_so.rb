class Rules::EnrolledInSo < Rule
  def clients_that_fit(scope, requirement)
    if Client.column_names.include?(:enrolled_in_so.to_s)
      scope.where(enrolled_in_so: requirement.positive)
    else
      raise RuleDatabaseStructureMissing, "clients.enrolled_in_so missing. Cannot check clients against #{self.class}."
    end
  end
end
