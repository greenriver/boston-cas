###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisions::Four
  class MatchRecommendationHsa < ::MatchDecisions::Base

    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::AcceptsNotWorkingWithClientReason

    # proxy for client.release_of_information
    attr_accessor :release_of_information
    # javascript toggle
    attr_accessor :working_with_client

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "Match Awaiting #{_('Housing Subsidy Administrator')} Review"
      when :accepted then "Match accepted by #{_('Housing Subsidy Administrator')}."
      when :declined then decline_status_label
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    private def decline_status_label
      [
        "Match declined by #{_('Housing Subsidy Administrator')}. Reason: #{decline_reason_name}",
      ].join ". "
    end


    def step_name
      "#{_('Housing Subsidy Administrator')} Initial Review of Match Recommendation"
    end

    def actor_type
      _('HSA')
    end

    def expires?
      true
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        declined: 'Declined',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Four::MatchRecommendationHsa
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact:
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :four_match_recommendation_hsa
    end

    private def note_present_if_status_declined
      if note.blank? && status == 'declined'
        errors.add :note, 'Please note why the match is declined.'
      end
    end

    private def decline_reason_scope
      # FIXME: this may be different
      MatchDecisionReasons::ShelterAgencyDecline.all
    end


    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        match.four_confirm_hsa_initial_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def decline_reason_blank?
      decline_reason.blank?
    end

  end
end

