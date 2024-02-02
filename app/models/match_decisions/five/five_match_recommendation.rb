###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveMatchRecommendation < Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultHsaDeclineReasons

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_related_active_match
    validate :ensure_required_contacts_present_on_accept

    def step_name
      "#{actor_type} Initial Review"
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def show_client_match_attributes?
      true
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Five::MatchRecommendation
      end
    end

    def permitted_params
      super + [:prevent_matching_until, :shelter_expiration]
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        declined: 'Decline',
        canceled: 'Canceled',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting #{actor_type} Review"
      when :accepted then "New Match Accepted by #{actor_type}"
      when :declined then "New Match Declined by #{actor_type}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        match.rejected!
      end

      def canceled
        Notifications::Five::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    private def cant_accept_if_match_closed
      errors.add :status, 'This match has already been closed.' if save_will_accept? && match.closed
    end

    private def cant_accept_if_related_active_match
      errors.add :status, 'There is already another active match for this opportunity' if save_will_accept? && match.opportunity_related_matches.active.any? && ! match_route.allow_multiple_active_matches
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{match_route.contact_label_for(:shelter_agency_contacts)} Contact" if save_will_accept? && match.shelter_agency_contacts.none?
      missing_contacts << "a #{match_route.contact_label_for(:housing_subsidy_admin_contacts)} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
