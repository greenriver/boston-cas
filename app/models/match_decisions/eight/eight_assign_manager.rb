###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Eight
  class EightAssignManager < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteEightCancelReasons

    validate :ensure_required_contacts_present_on_complete

    def step_name
      _("#{_('Housing Subsidy Administrator Eight')} Assigns Case Manager")
    end

    def actor_type
      _('Housing Subsidy Administrator Eight')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Eight::EightAssignManager
      end
    end

    def permitted_params
      super + [:manager]
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        completed: 'Completed',
        declined: 'Declined',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then 'Awaiting Assigned Case Manager'
      when :expiration_update then 'Awaiting Assigned Case Manger'
      when :completed then "Match completed by #{_('Housing Subsidy Administrator Eight')}, assigned Case Manager #{manager}"

      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def status_label
      if match.eight_confirm_assign_manager_decline_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
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
      end

      def declined
        Notifications::MatchDeclined.create_for_match!(match)
        match.eight_confirm_assign_manager_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match!(match)
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

    def step_decline_reasons(_contact)
      [
        'Other',
      ]
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :manager,
      )
    end

    private def ensure_required_contacts_present_on_complete
      missing_contacts = []
      missing_contacts << "a #{_('Housing Subsidy Administrator Eight')} Contact" if status == 'completed' && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
