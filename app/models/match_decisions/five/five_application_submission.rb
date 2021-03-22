###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveApplicationSubmission < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    def step_name
      _('Submit Client Application')
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
        m << Notifications::Five::ApplicationSubmission
      end
    end

    def permitted_params
      super + [:shelter_expiration]
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        accepted: 'Accept',
        declined: 'Decline',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting #{_('Route Five Shelter Agency')} Review"
      when :expiration_update then "New Match Awaiting #{_('Route Five Shelter Agency')} Review"
      when :accepted then "Client Application Submitted by #{_('Route Five Shelter Agency')}"
      when :declined then "New Match Declined by #{_('Route Five Shelter Agency')}.  Reason: #{decline_reason_name}"
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

      def accepted
        @decision.next_step.initialize_decision!

        if match.client.remote_id.present? && Warehouse::Base.enabled?
          Warehouse::Client.find_by(id: match.client.remote_id)&.queue_history_pdf_generation
        end
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
      MatchDecisionReasons::ShelterAgencyDecline.all
    end
  end
end
