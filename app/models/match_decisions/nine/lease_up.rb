###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class LeaseUp < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :client_move_in_date_present_if_status_complete

    def step_name
      _('Move In')
    end

    def actor_type
      _('HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::LeaseUp
      end
    end

    def permitted_params
      super + [:client_move_in_date, :prevent_matching_until]
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
      when :pending then 'Awaiting Move In'
      when :expiration_update then 'Awaiting Move In'
      when :completed then "Match completed by #{_('Housing Subsidy Administrator')}, lease start date #{client_move_in_date.try :strftime, '%m/%d/%Y'}"

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
        contact.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :nine_lease_up
    end

    private def decline_reason_scope(_contact)
      MatchDecisionReasons::HousingSubsidyAdminDecline.active
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :client_move_in_date,
      )
    end

    private def client_move_in_date_present_if_status_complete
      errors.add :client_move_in_date, 'must be filled in' if status == 'completed' && client_move_in_date.blank?
    end
  end
end