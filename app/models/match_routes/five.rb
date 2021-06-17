###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Five < Base
    def title
      _('Match Route Five')
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
        _('Route Five DND Contact')
      when :housing_subsidy_admin_contacts
        _('Route Five HSA')
      when :shelter_agency_contacts
        _('Route Five Shelter Agency')
      when :ssp_contacts
        _('Route Five Stabilization Service Provider')
      when :hsp_contacts
        _('Route Five Housing Search Provider')
      when :do_contacts
        _('Route Five Development Officer')
      end
    end
  end
end