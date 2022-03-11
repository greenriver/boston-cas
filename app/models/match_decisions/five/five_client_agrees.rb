###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveClientAgrees < Base
    include MatchDecisions::AcceptsDeclineReason

    def step_name
      _('Client Agrees To Match')
    end

    def contact_actor_type
      :shelter_agency_contacts
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
      super + [:prevent_matching_until]
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        declined: 'Decline',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "Match Awaiting #{actor_type} Review"
      when :accepted then "Match Accepted by #{actor_type} on Behalf of the Client"
      when :declined then "Match Declined by #{actor_type} on Behalf of the Client.  Reason: #{decline_reason_name}"
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

    private def decline_reason_scope(_contact)
      MatchDecisionReasons::ShelterAgencyDecline.all
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end
  end
end
