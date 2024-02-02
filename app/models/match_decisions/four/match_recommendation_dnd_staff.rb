###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Four
  class MatchRecommendationDndStaff < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultDndStaffDeclineReasons
    include MatchDecisions::RouteFourCancelReasons

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_related_active_match
    # validate :note_present_if_status_declined
    validate :ensure_required_contacts_present_on_accept

    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting #{_('DND')} Review"
      when :accepted then "New Match Accepted by #{_('DND')}"
      when :declined then "New Match Declined by #{_('DND')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{_('DND')} Initial Review"
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      nil
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accept',
        declined: 'Decline',
        canceled: 'Canceled',
        destroy: 'Destroy',
      }
    end

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def permitted_params
      super + [:prevent_matching_until, :shelter_expiration]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def accessible_by? contact
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def to_param
      :four_match_recommendation_dnd_staff
    end

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Four::MatchRecommendationDndStaff
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!

        return unless match.client.remote_id.present? && Warehouse::Base.enabled?

        Warehouse::Client.find_by(id: match.client.remote_id)&.queue_history_pdf_generation
      end

      def declined
        Notifications::Four::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    def cant_accept_if_match_closed
      errors.add :status, 'This match has already been closed.' if save_will_accept? && match.closed
    end

    def cant_accept_if_related_active_match
      errors.add :status, 'There is already another active match for this opportunity' if save_will_accept? && match.opportunity_related_matches.active.any? && ! match_route.allow_multiple_active_matches
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{_('Shelter Agency')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?

      missing_contacts << "a #{_('DND')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?

      missing_contacts << "a #{_('Housing Subsidy Administrator')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
