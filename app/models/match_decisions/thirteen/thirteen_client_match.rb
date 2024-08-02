###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class ThirteenClientMatch < ::MatchDecisions::Base
    include MatchDecisions::RouteThirteenCancelReasons

    validate :ensure_required_contacts_present_on_accept
    validate :validate_cancel_reason

    def to_partial_path
      'match_decisions/thirteen/client_match'
    end

    def step_name
      'Client Match'
    end

    def actor_type
      Translation.translate('CoC Thirteen')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    # def accessible_by?(contact)
      # contact.user_can_act_on_behalf_of_match_contacts? ||
      # contact.in?(match.send(contact_actor_type))
    # end

    # def declineable_by?(contact)
    #   contact.user_can_act_on_behalf_of_match_contacts? ||
    #   contact.in?(match.shelter_agency_contacts)
    # end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Thirteen::ThirteenClientMatch
      end
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        canceled: 'Canceled',
        expiration_update: 'Pending',
      }
    end

    def permitted_params
      super + [:prevent_matching_until, :shelter_expiration]
    end

    def label_for_status status
      case status.to_sym
      when :pending, :expiration_update then "#{Translation.translate('CoC Thirteen')} assigned match"
      when :accepted then "Match accepted by #{Translation.translate('CoC Thirteen')}"
      when :canceled then canceled_status_label
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

    # Override default behavior
    def record_action_event! contact: d
      if status == 'expiration_update'
        # Make note of the new expiration
      else
        decision_action_events.create! match: match, contact: contact, action: status, note: note
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def expiration_update
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
