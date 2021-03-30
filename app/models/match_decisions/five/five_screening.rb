###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveScreening < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    def step_name
      _('Client Screening')
    end

    def actor_type
      _('Route Five Shelter Agency')
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    def show_client_match_attributes?
      true
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Five::Screening
      end
    end

    def permitted_params
      super + []
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        mitigation_required: "#{_('Mitigation required')}",
        mitigation_not_required: "#{_('No mitigation required')}",
        canceled: 'Canceled',
        declined: 'Declined',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Route Five Shelter Agency')} Screening Client"
      when :expiration_update then "#{_('Route Five Shelter Agency')} Screening Client"
      when :mitigation_required then "#{_('Route Five Shelter Agency')} #{_('determined mitigation required')}"
      when :mitigation_not_required then "#{_('Route Five Shelter Agency')} #{_('determined mitigation not required')}"
      when :declined then "Match Declined by #{_('Route Five Shelter Agency')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
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

      def expiration_update
      end

      def mitigation_required
        @decision.next_step.initialize_decision!
      end

      def mitigation_not_required
        # Set the next step status to approved and skip the next step
        @decision.next_step.update(status: :accepted)
        @decision.next_step.next_step.initialize_decision!
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
      super && saved_status !~ /mitigation_required|mitigation_not_required/
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def decline_reason_scope
      MatchDecisionReasons::ShelterAgencyDecline.all
    end
  end
end
