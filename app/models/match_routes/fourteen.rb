###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchRoutes
  class Fourteen < Base
    def title
      Translation.translate(untranslated_title)
    end

    def untranslated_title
      'Match Route Fourteen'
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Fourteen::FourteenInitiateMatch' => 1,
        'MatchDecisions::Fourteen::FourteenMatchAcknowledgement' => 2,
        'MatchDecisions::Fourteen::FourteenClientReview' => 3,
        'MatchDecisions::Fourteen::FourteenEligibilityScreening' => 4,
        'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening' => 5,
        'MatchDecisions::Fourteen::FourteenOfferUnit' => 6,
        'MatchDecisions::Fourteen::FourteenConfirmMatchSuccess' => 7,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Fourteen::FourteenInitiateMatch' => 1,
        'MatchDecisions::Fourteen::FourteenMatchAcknowledgement' => 2,
        'MatchDecisions::Fourteen::FourteenMatchAcknowledgementDecline' => 3,
        'MatchDecisions::Fourteen::FourteenClientReview' => 4,
        'MatchDecisions::Fourteen::FourteenClientReviewDecline' => 5,
        'MatchDecisions::Fourteen::FourteenEligibilityScreening' => 6,
        'MatchDecisions::Fourteen::FourteenEligibilityScreeningDecline' => 7,
        'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening' => 8,
        'MatchDecisions::Fourteen::FourteenSubsidyAdminScreeningDecline' => 9,
        'MatchDecisions::Fourteen::FourteenOfferUnit' => 10,
        'MatchDecisions::Fourteen::FourteenOfferUnitDecline' => 11,
        'MatchDecisions::Fourteen::FourteenConfirmMatchSuccess' => 12,
      }
    end

    def required_contact_types
      [
        'shelter_agency_contacts',
        'housing_subsidy_admin_contacts',
        'ssp_contacts',
        'hsp_contacts',
        'dnd_staff_contacts',
      ]
    end

    def contact_label_for(contact_type)
      case contact_type
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency Fourteen')
      when :housing_subsidy_admin_contacts
        Translation.translate('HSA Fourteen')
      when :ssp_contacts
        Translation.translate('Stabilization Service Providers Fourteen')
      when :hsp_contacts
        Translation.translate('Housing Search Provider Fourteen')
      when :dnd_staff_contacts
        Translation.translate('CoC Fourteen')
      else
        super
      end
    end

    def first_client_step
      'MatchDecisions::Fourteen::FourteenMatchAcknowledgement'
    end

    def client_reveal_step_for(contact_type)
      {
        hsp_contacts: 'MatchDecisions::Fourteen::FourteenEligibilityScreening',
        housing_subsidy_admin_contacts: 'MatchDecisions::Fourteen::FourteenSubsidyAdminScreening',
      }[contact_type]
    end

    def initial_decision
      :fourteen_initiate_match_decision
    end

    def success_decision
      :fourteen_confirm_match_success_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def status_declined?(match)
      [
        match.fourteen_match_acknowledgement_decision&.status == 'declined' &&
          match.fourteen_match_acknowledgement_decline_decision&.status != 'decline_overridden',
        match.fourteen_client_review_decision&.status == 'declined' &&
          match.fourteen_client_review_decline_decision&.status != 'decline_overridden',
        match.fourteen_eligibility_screening_decision&.status == 'declined' &&
          match.fourteen_eligibility_screening_decline_decision&.status != 'decline_overridden',
        match.fourteen_subsidy_admin_screening_decision&.status == 'declined' &&
          match.fourteen_subsidy_admin_screening_decline_decision&.status != 'decline_overridden',
        match.fourteen_offer_unit_decision&.status == 'declined' &&
          match.fourteen_offer_unit_decline_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
