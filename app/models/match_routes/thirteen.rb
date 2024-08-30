###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Thirteen < Base
    def title
      Translation.translate('Match Route Thirteen')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Thirteen::ThirteenClientMatch' => 1,
        'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement' => 2,
        'MatchDecisions::Thirteen::ThirteenClientReview' => 3,
        'MatchDecisions::Thirteen::ThirteenHearingScheduled' => 4,
        'MatchDecisions::Thirteen::ThirteenHearingOutcome' => 5,
        'MatchDecisions::Thirteen::ThirteenHsaReview' => 6,
        'MatchDecisions::Thirteen::ThirteenAcceptReferral' => 7,
        'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess' => 8,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Thirteen::ThirteenClientMatch' => 1,
        'MatchDecisions::Thirteen::ThirteenMatchAcknowledgement' => 2,
        'MatchDecisions::Thirteen::ThirteenClientReview' => 3,
        'MatchDecisions::Thirteen::ThirteenClientReviewDecline' => 4,
        'MatchDecisions::Thirteen::ThirteenHearingScheduled' => 5,
        'MatchDecisions::Thirteen::ThirteenHearingScheduledDecline' => 6,
        'MatchDecisions::Thirteen::ThirteenHearingOutcome' => 7,
        'MatchDecisions::Thirteen::ThirteenHearingOutcomeDecline' => 8,
        'MatchDecisions::Thirteen::ThirteenHsaReview' => 9,
        'MatchDecisions::Thirteen::ThirteenHsaReviewDecline' => 10,
        'MatchDecisions::Thirteen::ThirteenAcceptReferral' => 11,
        'MatchDecisions::Thirteen::ThirteenAcceptReferralDecline' => 12,
        'MatchDecisions::Thirteen::ThirteenConfirmMatchSuccess' => 13,
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
        Translation.translate('Shelter Agency Thirteen')
      when :housing_subsidy_admin_contacts
        Translation.translate('HSA Thirteen')
      when :ssp_contacts
        Translation.translate('Stabilization Service Providers Thirteen')
      when :hsp_contacts
        Translation.translate('Housing Search Provider Thirteen')
      when :dnd_staff_contacts
        Translation.translate('CoC Thirteen')
      else
        super
      end
    end

    def initial_decision
      :thirteen_client_match_decision
    end

    def success_decision
      :thirteen_confirm_match_success_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def status_declined?(match)
      [
        match.thirteen_client_review_decision&.status == 'declined' &&
          match.thirteen_client_review_decline_decision&.status != 'decline_overridden',
        match.thirteen_hearing_scheduled_decision&.status == 'declined' &&
          match.thirteen_hearing_scheduled_decline_decision&.status != 'decline_overridden',
        match.thirteen_hearing_outcome_decision&.status == 'declined' &&
          match.thirteen_hearing_outcome_decline_decision&.status != 'decline_overridden',
        match.thirteen_hsa_review_decision&.status == 'declined' &&
          match.thirteen_hsa_review_decline_decision&.status != 'decline_overridden',
        match.thirteen_accept_referral_decision&.status == 'declined' &&
          match.thirteen_accept_referral_decline_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
