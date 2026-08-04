###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Thirteen
  class ThirteenConfirmMatchSuccess < Base
    include MatchDecisions::RouteEightCancelReasons

    def statuses
      {
        pending: 'Pending',
        confirmed: 'Confirmed',
        rejected: 'Rejected',
        canceled: 'Canceled', # added to support cancellations caused by other match success
        back: 'Pending',
      }
    end

    def to_partial_path
      'match_decisions/thirteen/confirm_match_success'
    end

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('CoC Thirteen')} to confirm match success"
      when :confirmed then "#{Translation.translate('CoC Thirteen')} confirms match success"
      when :rejected then "Match rejected by #{Translation.translate('CoC Thirteen')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      Translation.translate('Confirm Match Success')
    end

    def actor_type
      Translation.translate('CoC Thirteen')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Thirteen::ThirteenConfirmMatchSuccessHsa
        m << Notifications::Thirteen::ThirteenConfirmMatchSuccessShelterAgency
        m << Notifications::Thirteen::ThirteenConfirmMatchSuccessDndStaff
        m << Notifications::Thirteen::ThirteenConfirmMatchSuccessSsp
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmed.create_for_match! match
        match.succeeded!(user: user)
      end

      def rejected
        Notifications::MatchRejected.create_for_match! match
        match.rejected!
      end
    end
    private_constant :StatusCallbacks
  end
end
