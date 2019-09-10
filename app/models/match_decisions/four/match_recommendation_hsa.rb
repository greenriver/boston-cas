###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisions::Four
  class MatchRecommendationHsa < Base

    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::AcceptsNotWorkingWithClientReason

    # proxy for client.release_of_information
    attr_accessor :release_of_information
    # javascript toggle
    attr_accessor :working_with_client
    # validate :note_present_if_status_declined
    validate :release_of_information_present_if_match_accepted
    validate :spoken_with_services_agency_and_cori_release_submitted_if_accepted

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "Match Awaiting #{_('Housing Subsidy Administrator')} Review"
      when :acknowledged then "Match acknowledged by #{_('Housing Subsidy Administrator')}.  In review"
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
      _('Housing Subsidy Administrator')
    end

    def expires?
      true
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    def statuses
      {
        pending: 'Pending',
        acknowledged: 'Acknowledged',
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
      Notifications::Four::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.shelter_agency_contacts)
    end

    private def note_present_if_status_declined
      if note.blank? && status == 'declined'
        errors.add :note, 'Please note why the match is declined.'
      end
    end

    private def decline_reason_scope
      MatchDecisionReasons::ShelterAgencyDecline.all
    end


    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def acknowledged
      end

      def accepted
        # Only update the client's release_of_information attribute if we just set it
        if @decision.release_of_information == '1'
          match.client.update_attribute(:release_of_information, Time.now)
        end
        @decision.next_step.initialize_decision!
      end

      def declined
        match.confirm_shelter_agency_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def release_of_information_present_if_match_accepted
      # if the Shelter Agency has just indicated a release has been signed:
      # release_of_information = '1'
      # if the client previously signed the release
      # release_of_information = Time
      if status == 'accepted' && release_of_information == '0'
        errors.add :release_of_information, 'Client must provide a release of information to move forward in the match process'
      end
    end

    private def spoken_with_services_agency_and_cori_release_submitted_if_accepted
      if status == 'accepted'
        if ! client_spoken_with_services_agency
          errors.add :client_spoken_with_services_agency, 'Communication with the services agency is required.'
        end
        if Config.get(:require_cori_release) && ! cori_release_form_submitted
         errors.add :cori_release_form_submitted, 'A CORI release form is required.'
        end
      end
    end

    private def decline_reason_blank?
      decline_reason.blank?
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :release_of_information,
        :client_spoken_with_services_agency,
        :cori_release_form_submitted,
      )
    end
  end
end

