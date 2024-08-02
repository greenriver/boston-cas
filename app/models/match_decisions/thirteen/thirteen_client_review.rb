###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class ThirteenClientReview < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteThirteenCancelReasons
    include MatchDecisions::RouteThirteenDeclineReasons

    validate :ensure_required_contacts_present_on_accept
    validate :validate_cancel_reason

    def to_partial_path
      'match_decisions/thirteen/client_review'
    end

    def step_name
      'Client Review'
    end

    def actor_type
      Translation.translate('Shelter Agency Thirteen')
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Thirteen::ThirteenClientReviewShelterAgency
        m << Notifications::Thirteen::ThirteenClientReviewHsa
        m << Notifications::Thirteen::ThirteenClientReviewDndStaff
      end
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        canceled: 'Canceled',
        declined: 'Declined',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Shelter Agency Thirteen')} assigned match"
      when :accepted then "Match accepted by #{Translation.translate('Shelter Agency Thirteen')}."
      when :canceled then canceled_status_label
      when :declined then 'Match Declined'
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('Shelter Agency Thirteen')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def validate_cancel_reason
      errors.add :administrative_cancel_reason_id, 'please indicate the reason for canceling' if status == 'canceled' && administrative_cancel_reason_id.blank?

      errors.add :administrative_cancel_reason_other_explanation, "must be filled in if choosing 'Other'" if status == 'canceled' && administrative_cancel_reason&.other? && administrative_cancel_reason_other_explanation.blank?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'confirmed'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        if match.sub_program.cori_hearing_required?
          @decision.next_step.initialize_decision!
        else
          match.thirteen_hearing_scheduled_decision.update(status: :skipped)
          match.thirteen_hearing_outcome_decision.update(status: :skipped)
          match.thirteen_hsa_review_decision.initialize_decision!
        end
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.thirteen_client_review_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
