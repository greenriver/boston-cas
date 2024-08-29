###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::HomelessSetAside
  class SetAsidesHsaAcknowledgesReceipt < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :cant_accept_if_match_closed
    validate :can_only_accept_an_opportunity_once
    validate :ensure_required_contacts_present_on_accept

    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting Acknowledgment by #{Translation.translate('HSA')}"
      when :acknowledged then "Match acknowledged by #{Translation.translate('HSA')}.  In review"
      when :canceled then canceled_status_label
      end
    end

    def started?
      status&.to_sym == :acknowledged
    end

    def step_name
      "New Match for #{Translation.translate('HSA')}"
    end

    def actor_type
      Translation.translate('HSA')
    end

    def contact_actor_type
      nil
    end

    def statuses
      {
        pending: 'Pending',
        acknowledged: 'Acknowledged',
        canceled: 'Canceled',
      }
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::HomelessSetAside::MatchInitiationForHsa
        m << Notifications::HomelessSetAside::MatchInitiationForShelterAgency
        m << Notifications::HomelessSetAside::MatchInitiationForSsp
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def acknowledged
        @decision.next_step.initialize_decision!

        return unless match.client.remote_id.present? && Warehouse::Base.enabled?

        begin
          Warehouse::Client.find(match.client.remote_id).queue_history_pdf_generation
        rescue StandardError
          nil
        end
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def save_will_accept?
      saved_status == 'pending' && status == 'acknowledged'
    end

    def cant_accept_if_match_closed
      return unless save_will_accept? && match.closed

      errors.add :status, 'This match has already been closed.'
    end

    def can_only_accept_an_opportunity_once
      return unless save_will_accept? && match.already_active_for_opportunity.any?

      errors.add :status, 'The receipt of this opportunity has already been acknowledged'
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('DND')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?

      missing_contacts << "a #{Translation.translate('Housing Subsidy Administrator')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      return unless missing_contacts.any?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}"
    end
  end
end
