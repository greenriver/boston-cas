###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class ThirteenClientReview < Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteThirteenCancelReasons
    include MatchDecisions::RouteThirteenDeclineReasons

    # proxy for client.release_of_information
    attr_accessor :release_of_information

    validate :ensure_required_contacts_present_on_accept
    validate :release_of_information_present_if_match_accepted
    validate :spoken_with_services_agency_and_cori_release_submitted_if_accepted

    def to_partial_path
      'match_decisions/thirteen/client_review'
    end

    def step_name
      'Client Review'
    end

    def actor_type
      Translation.translate('Shelter Agency Thirteen')
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Thirteen::ThirteenClientReviewShelterAgency
        m << Notifications::Thirteen::ThirteenClientReviewHsa
        m << Notifications::Thirteen::ThirteenClientReviewDndStaff
      end
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        canceled: 'Canceled',
        declined: 'Declined',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Shelter Agency Thirteen')} assigned match"
      when :accepted then "Match accepted by #{Translation.translate('Shelter Agency Thirteen')}."
      when :canceled then canceled_status_label
      when :declined then 'Match Declined'
      when :back then backup_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def expires?
      true
    end

    def stallable?
      true
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('Shelter Agency Thirteen')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    def permitted_params
      super + [:client_spoken_with_services_agency, :cori_release_form_submitted, :release_of_information, :shelter_expiration]
    end

    private def release_of_information_present_if_match_accepted
      # if the Shelter Agency has just indicated a release has been signed:
      # release_of_information = '1'
      # if the client previously signed the release
      # release_of_information = Time
      errors.add :release_of_information, 'Client must provide a release of information to move forward in the match process' if status == 'accepted' && release_of_information == '0'
    end

    private def spoken_with_services_agency_and_cori_release_submitted_if_accepted
      if status == 'accepted' # rubocop:disable Style/GuardClause
        errors.add :client_spoken_with_services_agency, 'Communication with the services agency is required.' unless client_spoken_with_services_agency
        errors.add :cori_release_form_submitted, 'A CORI release form is required.' if Config.get(:require_cori_release) && ! cori_release_form_submitted
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        # Only update the client's release_of_information attribute if we just set it
        match.client.update_attribute(:release_of_information, Time.current) if @decision.release_of_information == '1'
        if match.sub_program.cori_hearing_required?
          @decision.next_step.initialize_decision!
        else
          match.thirteen_hearing_scheduled_decision.update(status: :skipped)
          match.thirteen_hearing_outcome_decision.update(status: :skipped)
          match.thirteen_hsa_review_decision.initialize_decision!
        end
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.thirteen_client_review_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
