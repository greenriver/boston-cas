###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Eight < Base
    def title
      _('Match Route Eight')
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

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        _('DND')
      when :housing_subsidy_admin_contacts
        _('HSA Eight')
      when :shelter_agency_contacts
        _('Shelter Agency Eight')
      when :ssp_contacts
        _('Stabilization Service Provider Eight')
      when :hsp_contacts
        _('Housing Search Provider Eight')
      when :do_contacts
        _('Development Officer Eight')
      end
    end
  end
end
