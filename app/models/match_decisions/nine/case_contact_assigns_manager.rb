###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class CaseContactAssignsManager < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :manager_present_if_status_complete

    def step_name
      _("#{_('Stabilization Service Provider Nine')} Assigns Case Manager")
    end

    def actor_type
      _('Stabilization Service Provider Nine')
    end

    def contact_actor_type
      :ssp_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::CaseContactAssignsManager
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
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then 'Awaiting Assigned Case Manager'
      when :expiration_update then 'Awaiting Assigned Case Manger'
      when :completed then "Match completed by #{_('Stabilization Service Provider Nine')}, assigned Case Manager #{manager}"

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
        contact.in?(match.ssp_contacts)
    end

    def to_param
      :case_contact_assigns_manager
    end

    private def decline_reason_scope(_contact)
      MatchDecisionReasons::CaseContactAssignsManagerDecline.active
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :manager,
      )
    end

    private def manager_present_if_status_complete
      errors.add :manager, 'must be filled in' if status == 'completed' && manager.blank?
    end
  end
end
