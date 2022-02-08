###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveMitigation < Base
    include MatchDecisions::AcceptsDeclineReason

    attr_accessor :mitigations

    def step_name
      _('Mitigation')
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    def show_client_match_attributes?
      true
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Five::Mitigation
      end
    end

    def permitted_params
      super + [mitigations: []]
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        accepted: 'Completed',
        canceled: 'Canceled',
        declined: 'Declined',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{actor_type} Mitigation"
      when :expiration_update then "#{actor_type} Mitigation"
      when :accepted then "Mitigation completed by #{actor_type}."
      when :declined then "Match Declined by #{actor_type}.  Reason: #{decline_reason_name}"
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
        record_mitigations
        @decision.next_step.initialize_decision!
      end

      def declined
        record_mitigations
        match.rejected!
      end

      def canceled
        record_mitigations
        Notifications::Five::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def record_mitigations
        return unless @decision.mitigations.present?

        mitigation_ids = @decision.mitigations.select{ |str| str.present? }.map(&:to_i)
        match.match_mitigation_reasons.where(id: mitigation_ids).update(addressed: true)
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
      MatchDecisionReasons::MitigationDecline.all
    end
  end
end
