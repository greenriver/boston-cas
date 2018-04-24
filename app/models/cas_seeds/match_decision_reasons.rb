module CasSeeds
  class MatchDecisionReasons
    
    DND_REASONS = [
      "Client won't be eligible for services",
      "Client won't be eligible for housing type",
      "Client won't be eligible based on funding source",
      "Client has another housing option",
    ]

    HSA_REASONS = [
      "CORI",
      "SORI",
      "Immigration status",
      'Household did not respond after initial acceptance of match',
      'Ineligible for Housing Program',
      'Client refused offer',
      'Self-resolved',
      'Falsification of documents',
      'Additional screening criteria imposed by third parties',
      'Health and Safety',
    ]

    HSA_PRIORITY_ONLY_REASONS = [
      'Household did not respond',
      'Ineligible for Housing Program',
      'Client refused offer',
      'Self-resolved',
      'Falsification of documents',
      'Health and Safety',
    ]

    SHELTER_AGENCY_REASONS = [
      "Does not agree to services",
      "Unwilling to live in that neighborhood",
      "Unwilling to live in SRO",
      "Does not want housing at this time",
      "Unsafe environment for this person",
      "Client has another housing option",
    ]

    SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS = [
      "Barred from working with agency",
      "Hospitalized",
      "Don’t know / disappeared",
      "Incarcerated",
    ]

    ADMINISTRATIVE_CANCEL_REASONS = [
      'Match expired',
      'Client has declined match',
      'Client has disengaged',
      'Client has disappeared',
      'SSP CORI',
      'HSP CORI',
      'Incarcerated',
      'Vacancy should not have been entered',
      'Client received another housing opportunity',
      'Client no longer eligible for match',
      'Client deceased'
    ]

    def run!
      create_other_reason!
      create_dnd_reasons!
      create_hsa_reasons!
      create_hsa_priority_reasons!
      create_shelter_agency_reasons!
      create_shelter_agency_not_working_with_client_reasons!
      create_shelter_agency_not_working_with_client_other_reason!
      create_admin_cancel_reasons!
    end

    private def create_other_reason!
      ::MatchDecisionReasons::Other.all.first_or_create! name: "Other"
    end
    

    private def create_dnd_reasons!
      DND_REASONS.each do |reason_name|
        ::MatchDecisionReasons::DndStaffDecline.where(name: reason_name).first_or_create!
      end    
    end

    private def create_hsa_reasons!
      HSA_REASONS.each do |reason_name|
        ::MatchDecisionReasons::HousingSubsidyAdminDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_hsa_priority_reasons!
      HSA_PRIORITY_ONLY_REASONS.each do |reason_name|
        ::MatchDecisionReasons::HousingSubsidyAdminPriorityDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_shelter_agency_reasons!
      SHELTER_AGENCY_REASONS.each do |reason_name|
        ::MatchDecisionReasons::ShelterAgencyDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_shelter_agency_not_working_with_client_reasons!
      SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS.each do |reason_name|
        ::MatchDecisionReasons::ShelterAgencyNotWorkingWithClient.where(name: reason_name).first_or_create!
      end
    end

    private def create_shelter_agency_not_working_with_client_other_reason!
      ::MatchDecisionReasons::ShelterAgencyNotWorkingWithClientOther.all.first_or_create! name: 'Other'
    end

    private def create_admin_cancel_reasons!
      ADMINISTRATIVE_CANCEL_REASONS.each do |reason_name|
        ::MatchDecisionReasons::AdministrativeCancel.where(name: reason_name).first_or_create!
      end    
    end

  end
end