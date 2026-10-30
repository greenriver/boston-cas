###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Fourteen
  class FourteenInitiateMatch < Base
    validate :ensure_required_contacts_present_on_accept

    def to_partial_path
      'match_decisions/fourteen/initiate_match'
    end

    def step_name
      'Initiate Match'
    end

    def actor_type
      Translation.translate('CoC Fourteen')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Fourteen::FourteenInitiateMatchDndStaff
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
      when :pending, :expiration_update then "#{Translation.translate('CoC Fourteen')} assigned match"
      when :accepted then "Match accepted by #{Translation.translate('CoC Fourteen')}"
      when :canceled then canceled_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def required_contact_types
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :hsp_contacts]
    end

    private def ensure_required_contacts_present_on_accept
      return unless save_will_accept?

      missing_contacts = required_contact_types.select { |type| match.send(type).none? }.map do |type|
        "a #{match.match_route.contact_label_for(type)} Contact"
      end
      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    # Override default behavior
    def record_action_event! contact:
      if status == 'expiration_update'
        # Make note of the new expiration
      else
        decision_action_events.create! match: match, contact: contact, action: status, note: note
      end
    end

    def expires?
      true
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
