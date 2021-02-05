###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module CasSeeds
  class MatchDecisionReasons

    CLIENT_REJECTED = 2
    PROVIDER_REJECTED = 3

    DND_REASONS = [
      ["Client won't be eligible for services", nil],
      ["Client won't be eligible for housing type", nil],
      ["Client won't be eligible based on funding source", nil],
      ['Client has another housing option', nil],
    ].freeze

    HSA_REASONS = [
      ['CORI', nil],
      ['SORI', nil],
      ['Immigration status', nil],
      ['Household did not respond after initial acceptance of match', nil],
      ['Ineligible for Housing Program', nil],
      ['Client refused offer', nil],
      ['Self-resolved', nil],
      ['Falsification of documents', nil],
      ['Additional screening criteria imposed by third parties', nil],
      ['Health and Safety', nil],
    ].freeze

    HSA_PROVIDER_ONLY_REASONS = [
      ['Household could not be located', nil],
      ['Ineligible for Housing Program', nil],
      ['Client refused offer', nil],
      ['Health and Safety', nil],
    ].freeze

    SHELTER_AGENCY_REASONS = [
      ['Does not agree to services', nil],
      ['Unwilling to live in that neighborhood', nil],
      ['Unwilling to live in SRO', nil],
      ['Does not want housing at this time', nil],
      ['Unsafe environment for this person', nil],
      ['Client has another housing option', nil],
    ].freeze

    SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS = [
      ['Barred from working with agency', nil],
      ['Hospitalized', nil],
      ['Don’t know / disappeared', nil],
      ['Incarcerated', nil],
    ].freeze

    ADMINISTRATIVE_CANCEL_REASONS = [
      ['Match expired', nil],
      ['Client has declined match', nil],
      ['Client has disengaged', nil],
      ['Client has disappeared', nil],
      ['SSP CORI', nil],
      ['HSP CORI', nil],
      ['Incarcerated', nil],
      ['Vacancy should not have been entered', nil],
      ['Client received another housing opportunity', nil],
      ['Client no longer eligible for match', nil],
      ['Client deceased', nil],
      ['Vacancy filled by other client', nil],
    ].freeze

    def run!
      create_other_reason!
      create_dnd_reasons!
      create_hsa_reasons!
      create_hsa_provider_only_reasons!
      create_shelter_agency_reasons!
      create_shelter_agency_not_working_with_client_reasons!
      create_shelter_agency_not_working_with_client_other_reason!
      create_admin_cancel_reasons!
    end

    private def create_other_reason!
      reason = ::MatchDecisionReasons::Other.all.first_or_create! name: 'Other'
      reason.update(referral_result: nil)
    end


    private def create_dnd_reasons!
      DND_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::DndStaffDecline.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

    private def create_hsa_reasons!
      HSA_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::HousingSubsidyAdminDecline.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

    private def create_hsa_provider_only_reasons!
      ::MatchDecisionReasons::HousingSubsidyAdminPriorityDecline.update_all(active: false)
      HSA_PROVIDER_ONLY_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::HousingSubsidyAdminPriorityDecline.where(name: reason_name).first_or_create!
        reason.update(active: true, referral_result: referral_result)
      end
    end

    private def create_shelter_agency_reasons!
      SHELTER_AGENCY_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::ShelterAgencyDecline.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

    private def create_shelter_agency_not_working_with_client_reasons!
      SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::ShelterAgencyNotWorkingWithClient.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

    private def create_shelter_agency_not_working_with_client_other_reason!
      reason = ::MatchDecisionReasons::ShelterAgencyNotWorkingWithClientOther.all.first_or_create! name: 'Other'
      reason.update(referral_result: nil)
    end

    private def create_admin_cancel_reasons!
      ADMINISTRATIVE_CANCEL_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::AdministrativeCancel.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

  end
end
