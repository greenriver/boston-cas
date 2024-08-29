###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineAssignManager < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteNineDeclineReasons
    include MatchDecisions::RouteNineCancelReasons

    validate :manager_present_if_status_complete

    def step_name
      Translation.translate("#{Translation.translate('Stabilization Service Provider Nine')} Assigns Case Manager")
    end

    def actor_type
      Translation.translate('Stabilization Service Provider Nine')
    end

    def contact_actor_type
      :ssp_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::NineAssignManager
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
      when :completed then "Match completed by #{Translation.translate('Stabilization Service Provider Nine')}, assigned Case Manager #{manager}"

      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def status_label
      if match.nine_confirm_assign_manager_decline_decision.status == 'decline_overridden'
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
        match.nine_confirm_assign_manager_decline_decision.initialize_decision!
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

    private def manager_present_if_status_complete
      errors.add :manager, 'must be filled in' if status == 'completed' && manager.blank?
    end
  end
end
