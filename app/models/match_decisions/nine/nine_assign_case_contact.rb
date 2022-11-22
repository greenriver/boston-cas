###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineAssignCaseContact < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :ensure_required_contacts_present_on_accept

    def step_name
      "#{_('DND')} Assigns #{_('Stabilization Service Provider Nine')}"
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::NineAssignCaseContact
      end
    end

    def statuses
      {
        pending: 'Pending',
        completed: 'Completed',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then 'Case Contact Assignment'
      when :expiration_update then 'Case Contact Assignment'
      when :completed then "Case Contact Assigned by #{_('DND')}"

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

      def completed
        @decision.next_step.initialize_decision!
        return unless Warehouse::Base.enabled?

        match.active_referral_event&.accepted
        match.init_referral_event
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def started?
      status&.to_sym == :completed
    end

    def editable?
      super && saved_status !~ /completed|declined/
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
        contact.in?(match.send(contact_actor_type))
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :client_move_in_date,
      )
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{_('DND')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?
      missing_contacts << "a #{_('Stabilization Service Provider Nine')} Contact" if save_will_accept? && match.ssp_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
