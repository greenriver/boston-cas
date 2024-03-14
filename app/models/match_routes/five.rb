###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Five < Base
    def title
      Translation.translate('Match Route Five')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Five::FiveMatchRecommendation' => 1,
        'MatchDecisions::Five::FiveClientAgrees' => 2,
        'MatchDecisions::Five::FiveApplicationSubmission' => 3,
        'MatchDecisions::Five::FiveScreening' => 4,
        'MatchDecisions::Five::FiveMitigation' => 5,
        'MatchDecisions::Five::FiveLeaseUp' => 6,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Five::FiveMatchRecommendation' => 1,
        'MatchDecisions::Five::FiveClientAgrees' => 2,
        'MatchDecisions::Five::FiveApplicationSubmission' => 3,
        'MatchDecisions::Five::FiveScreening' => 4,
        'MatchDecisions::Five::FiveMitigation' => 5,
        'MatchDecisions::Five::FiveLeaseUp' => 6,
      }
    end

    def initial_decision
      :five_match_recommendation_decision
    end

    def success_decision
      :five_lease_up_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def required_contact_types
      [
        'housing_subsidy_admin',
        'shelter_agency',
      ]
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        Translation.translate('Route Five DND Contact')
      when :housing_subsidy_admin_contacts
        Translation.translate('Route Five HSA')
      when :shelter_agency_contacts
        Translation.translate('Route Five Shelter Agency')
      when :ssp_contacts
        Translation.translate('Route Five Stabilization Service Provider')
      when :hsp_contacts
        Translation.translate('Route Five Housing Search Provider')
      when :do_contacts
        Translation.translate('Route Five Development Officer')
      end
    end

    def status_declined?(match)
      [
        match.five_match_recommendation_decision&.status == 'declined',
        match.five_client_agrees_decision&.status == 'declined',
        match.five_screening_decision&.status == 'declined',
        match.five_mitigation_decision&.status == 'declined',
      ].any?
    end
  end
end
