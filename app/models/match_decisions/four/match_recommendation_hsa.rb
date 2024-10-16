###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Four
  class MatchRecommendationHsa < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::AcceptsNotWorkingWithClientReason
    include MatchDecisions::DefaultShelterAgencyDeclineReasons
    include MatchDecisions::RouteFourCancelReasons

    # proxy for client.release_of_information
    attr_accessor :release_of_information
    # javascript toggle
    attr_accessor :working_with_client

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "Match Awaiting #{Translation.translate('Housing Subsidy Administrator')} Review"
      when :accepted then "Match accepted by #{Translation.translate('Housing Subsidy Administrator')}."
      when :declined then decline_status_label
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    private def decline_status_label
      [
        "Match declined by #{Translation.translate('Housing Subsidy Administrator')}. Reason: #{decline_reason_name}",
      ].join '. '
    end

    def step_name
      "#{Translation.translate('Housing Subsidy Administrator')} Initial Review of Match Recommendation"
    end

    def actor_type
      Translation.translate('HSA')
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

    def stallable?
      true
    end

    def stalled_contact_types
      @stalled_contact_types ||= [
        :shelter_agency_contacts,
        :housing_subsidy_admin_contacts,
        :ssp_contacts,
        :hsp_contacts,
      ]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Four::MatchRecommendationHsa
        m << Notifications::Four::ShelterAgencyAccepted
        m << Notifications::Four::MatchRecommendationToHsaForSsp
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact&.user_can_act_on_behalf_of_match_contacts? ||
      contact&.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :four_match_recommendation_hsa
    end

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        Notifications::Four::MatchDeclined.create_for_match! match
        match.four_confirm_hsa_initial_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def decline_reason_blank?
      decline_reason.blank?
    end
  end
end
