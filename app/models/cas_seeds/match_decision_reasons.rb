###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
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

    LIMITED_HSA_REASONS = [
      ['Client needs higher level of care', PROVIDER_REJECTED],
      ['Unable to reach client after multiple attempts', nil],
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
      ['Client refused unit (non-SRO)', CLIENT_REJECTED],
      ['Client refused voucher', CLIENT_REJECTED],
    ].freeze

    MITIGATION_REASONS = [
      ['Mitigation failed', nil],
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

    LIMITED_ADMINISTRATIVE_CANCEL_REASONS = [
      ['Match expired – No agency interaction', nil],
      ['Match expired – Agency interaction', nil],
      ['Match stalled - Agency has disengaged', nil],
      ['Match expired – No Housing Case Manager interaction', nil],
      ['Match expired – No Shelter Agency interaction', nil],
      ['Shelter Agency has disengaged', nil],
      ['Housing Case Manager has disengaged', nil],
      ['Match stalled – Housing Case Manager has disengaged', nil],
      ['Client needs higher level of care', nil],
      ['Unable to reach client after multiple attempts', nil],
    ].freeze

    NINE_RECORD_VOUCHER_DATE_DECLINE_REASONS = [
      [' Household became disengaged', nil],
    ].freeze

    NINE_CASE_CONTACT_ASSIGNS_MANAGER_DECLINE_REASONS = [].freeze

    CASE_CONTACT_ASSIGNS_MANAGER_DECLINE_REASONS = [].freeze

    OTHER = [
      ['Other', nil],
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
      create_record_voucher_decline_reasons!
      create_case_contact_assigns_manager_decline_reasons!
      create_nine_case_contact_assigns_manager_decline_reasons!
      create_base_reasons!
    end

    private def create_base_reasons!
      reasons = DND_REASONS +
      HSA_REASONS +
      LIMITED_HSA_REASONS +
      HSA_PROVIDER_ONLY_REASONS +
      SHELTER_AGENCY_REASONS +
      MITIGATION_REASONS +
      SHELTER_AGENCY_NOT_WORKING_WITH_CLIENT_REASONS +
      ADMINISTRATIVE_CANCEL_REASONS +
      LIMITED_ADMINISTRATIVE_CANCEL_REASONS +
      OTHER
      reasons.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::All.where(name: reason_name).first_or_create!
        reason.update(referral_result: referral_result)
      end
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

      LIMITED_HSA_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::HousingSubsidyAdminDecline.where(name: reason_name, limited: true).first_or_create!
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

      LIMITED_ADMINISTRATIVE_CANCEL_REASONS.each do |reason_name, referral_result|
        reason = ::MatchDecisionReasons::AdministrativeCancel.where(name: reason_name, limited: true).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end

    private def create_mitigation_reasons!
      MITIGATION_REASONS.each do |reason_name, _|
        ::MatchDecisionReasons::MitigationDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_record_voucher_decline_reasons!
      NINE_RECORD_VOUCHER_DATE_DECLINE_REASONS.each do |reason_name, _|
        ::MatchDecisionReasons::NineRecordVoucherDateDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_case_contact_assigns_manager_decline_reasons!
      CASE_CONTACT_ASSIGNS_MANAGER_DECLINE_REASONS.each do |reason_name, _|
        ::MatchDecisionReasons::CaseContactAssignsManagerDecline.where(name: reason_name).first_or_create!
      end
    end

    private def create_nine_case_contact_assigns_manager_decline_reasons!
      NINE_CASE_CONTACT_ASSIGNS_MANAGER_DECLINE_REASONS.each do |reason_name, _|
        ::MatchDecisionReasons::NineCaseContactAssignsManagerDecline.where(name: reason_name).first_or_create!
      end
    end
  end
end
