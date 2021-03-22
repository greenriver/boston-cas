###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveClientAgrees < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_related_active_match
    validate :ensure_required_contacts_present_on_accept

    def step_name
      _('Client Agrees To Match')
    end

    def actor_type
      _('Route Five HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def show_client_match_attributes?
      true
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Five::ClientAgrees
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
      when :pending then "New Match Awaiting #{_('Route Five HSA')} Review"
      when :accepted then "New Match Accepted by #{_('Route Five HSA')}"
      when :declined then "New Match Declined by #{_('Route Five HSA')}.  Reason: #{decline_reason_name}"
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

    def started?
      status&.to_sym == :accepted
    end

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def decline_reason_scope
      MatchDecisionReasons::HousingSubsidyAdminDecline.all
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    private def cant_accept_if_match_closed
      errors.add :status, "This match has already been closed." if save_will_accept? && match.closed
    end

    private def cant_accept_if_related_active_match
      if save_will_accept? && match.opportunity_related_matches.active.any? && ! match_route.allow_multiple_active_matches
      then errors.add :status, "There is already another active match for this opportunity"
      end
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{_('Route Five Shelter Agency')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?
      missing_contacts << "a #{_('Route Five HSA')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
