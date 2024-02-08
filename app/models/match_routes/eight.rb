###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Eight < Base
    def title
      Translation.translate('Match Route Eight')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Eight::EightMatchRecommendation' => 1,
        'MatchDecisions::Eight::EightAssignManager' => 2,
        'MatchDecisions::Eight::EightRecordVoucherDate' => 3,
        'MatchDecisions::Eight::EightLeaseUp' => 4,
        # 'MatchDecisions::Eight::EightAssignCaseContact' => 5,
        'MatchDecisions::Eight::EightConfirmMatchSuccess' => 5,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Eight::EightMatchRecommendation' => 1,
        'MatchDecisions::Eight::EightAssignManager' => 2,
        'MatchDecisions::Eight::EightConfirmAssignManagerDecline' => 3,
        'MatchDecisions::Eight::EightRecordVoucherDate' => 4,
        'MatchDecisions::Eight::EightConfirmVoucherDecline' => 5,
        'MatchDecisions::Eight::EightLeaseUp' => 6,
        'MatchDecisions::Eight::EightConfirmLeaseUpDecline' => 7,
        # 'MatchDecisions::Eight::EightAssignCaseContact' => 6,
        'MatchDecisions::Eight::EightConfirmMatchSuccess' => 8,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :eight_match_recommendation_decision
    end

    def success_decision
      :eight_confirm_match_success_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def show_hearing_date
      false
    end

    def removed_hsa_reasons
      @removed_hsa_reasons ||= [
        'CORI',
        'SORI',
        'Falsification of documents',
        'Health and Safety',
        'Additional screening criteria imposed by third parties',
      ]
    end

    def additional_hsa_reasons
      @additional_hsa_reasons ||= [
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
      ]
    end

    def removed_admin_reasons
      @removed_admin_reasons ||= [
        'SSP CORI',
        'HSP CORI',
      ].freeze
    end

    def additional_admin_reasons
      @additional_admin_reasons ||= [
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
      ].freeze
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        Translation.translate('DND')
      when :housing_subsidy_admin_contacts
        Translation.translate('HSA Eight')
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency Eight')
      when :ssp_contacts
        Translation.translate('Stabilization Service Provider Eight')
      when :hsp_contacts
        Translation.translate('Housing Search Provider Eight')
      when :do_contacts
        Translation.translate('Development Officer Eight')
      end
    end

    def visible_contact_types
      [
        :dnd_staff_contacts,
        :housing_subsidy_admin_contacts,
      ]
    end

    def status_declined?(match)
      [
        match.eight_match_recommendation_decision&.status == 'declined',
        match.eight_assign_manager_decision&.status == 'declined' &&
          match.eight_confirm_assign_manager_decline_decision&.status != 'decline_overridden',
        match.eight_record_voucher_date_decision&.status == 'declined' &&
          match.eight_confirm_voucher_decline_decision&.status != 'decline_overridden',
        match.eight_lease_up_decision&.status == 'declined' &&
          match.eight_confirm_lease_up_decline_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
