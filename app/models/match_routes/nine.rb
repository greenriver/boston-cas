###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Nine < Base
    def title
      _('Match Route Nine')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Nine::NineMatchRecommendation' => 1,
        'MatchDecisions::Nine::NineRecordVoucherDate' => 2,
        'MatchDecisions::Nine::NineLeaseUp' => 3,
        'MatchDecisions::Nine::NineAssignCaseContact' => 4,
        'MatchDecisions::Nine::NineAssignManager' => 5,
        'MatchDecisions::Nine::NineConfirmMatchSuccess' => 6,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Nine::NineMatchRecommendation' => 1,
        'MatchDecisions::Nine::NineRecordVoucherDate' => 2,
        'MatchDecisions::Nine::NineConfirmVoucherDecline' => 3,
        'MatchDecisions::Nine::NineLeaseUp' => 4,
        'MatchDecisions::Nine::NineConfirmLeaseUpDecline' => 5,
        'MatchDecisions::Nine::NineAssignCaseContact' => 6,
        'MatchDecisions::Nine::NineAssignManager' => 7,
        'MatchDecisions::Nine::NineConfirmAssignManagerDecline' => 8,
        'MatchDecisions::Nine::NineConfirmMatchSuccess' => 9,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'shelter_agency_contacts',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :nine_match_recommendation_decision
    end

    def success_decision
      :nine_confirm_match_success_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def show_hearing_date
      false
    end

    def auto_initialize_event?
      false
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        _('DND')
      when :housing_subsidy_admin_contacts
        _('HSA Nine')
      when :shelter_agency_contacts
        _('Shelter Agency Nine')
      when :ssp_contacts
        _('Stabilization Service Provider Nine')
      when :hsp_contacts
        _('Housing Search Provider Nine')
      when :do_contacts
        _('Development Officer Nine')
      end
    end

    def visible_contact_types
      [
        :dnd_staff_contacts,
        :housing_subsidy_admin_contacts,
        :shelter_agency_contacts,
        :ssp_contacts,
      ]
    end

    def status_declined?(match)
      [
        match.nine_match_recommendation_decision&.status == 'declined',
        match.nine_record_voucher_date_decision&.status == 'declined' &&
          match.nine_confirm_voucher_decline_decline_decision&.status != 'decline_overridden',
        match.nine_lease_up_decision&.status == 'declined' &&
          match.nine_confirm_lease_up_decline_decision&.status != 'decline_overridden',
        match.nine_assign_manager_decision&.status == 'declined' &&
          match.nine_confirm_assign_manager_decline_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
