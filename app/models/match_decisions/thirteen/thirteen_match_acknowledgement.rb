###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class ThirteenMatchAcknowledgement < ::MatchDecisions::Base
    include MatchDecisions::RouteThirteenCancelReasons

    validate :ensure_required_contacts_present_on_accept

    def to_partial_path
      'match_decisions/thirteen/match_acknowledgement'
    end

    def step_name
      'Match Acknowledged'
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
        m << Notifications::Thirteen::ThirteenMatchAcknowledgementShelterAgency
        m << Notifications::Thirteen::ThirteenMatchAcknowledgementHsa
      end
    end

    def statuses
      {
        pending: 'Pending',
        acknowledged: 'Acknowledged',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Shelter Agency Thirteen')} assigned match"
      when :acknowledged then "Match acknowledged by #{Translation.translate('Shelter Agency Thirteen')}.  In review"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('Shelter Agency Thirteen')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'acknowledged'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def acknowledged
        @decision.next_step.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
