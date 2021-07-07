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
      ['CORI', PROVIDER_REJECTED],
      ['SORI', PROVIDER_REJECTED],
      ['Immigration status', nil],
      ['Household did not respond after initial acceptance of match', CLIENT_REJECTED],
      ['Ineligible for Housing Program', nil],
      ['Client refused offer', CLIENT_REJECTED],
      ['Self-resolved', nil],
      ['Falsification of documents', nil],
      ['Additional screening criteria imposed by third parties', PROVIDER_REJECTED],
      ['Health and Safety', nil],
    ].freeze

    HSA_PROVIDER_ONLY_REASONS = [
      ['Household could not be located', nil],
      ['Ineligible for Housing Program', nil],
      ['Client refused offer', CLIENT_REJECTED],
      ['Health and Safety', nil],
    ].freeze

    SHELTER_AGENCY_REASONS = [
      ['Does not agree to services', CLIENT_REJECTED],
      ['Unwilling to live in that neighborhood', CLIENT_REJECTED],
      ['Unwilling to live in SRO', CLIENT_REJECTED],
      ['Does not want housing at this time', CLIENT_REJECTED],
      ['Unsafe environment for this person', CLIENT_REJECTED],
      ['Client has another housing option', nil],
    ].freeze

    SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS = [
      ['Barred from working with agency', PROVIDER_REJECTED],
      ['Hospitalized', nil],
      ['Don’t know / disappeared', nil],
      ['Incarcerated', nil],
    ].freeze

    ADMINISTRATIVE_CANCEL_REASONS = [
      ['Match expired', nil],
      ['Client has declined match', CLIENT_REJECTED],
      ['Client has disengaged', CLIENT_REJECTED],
      ['Client has disappeared', CLIENT_REJECTED],
      ['SSP CORI', PROVIDER_REJECTED],
      ['HSP CORI', PROVIDER_REJECTED],
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
      create_mitigation_reasons!
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

    private def create_mitigation_reasons!
      MITIGATION_REASONS.each do |reason_name|
        ::MatchDecisionReasons::MitigationDecline.where(name: reason_name).first_or_create!
      end
    end
  end
end
