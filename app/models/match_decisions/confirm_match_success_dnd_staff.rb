module MatchDecisions
  class ConfirmMatchSuccessDndStaff < Base

    # validate :note_present_if_status_rejected

    def statuses
      {
        pending: 'Pending',
        confirmed: 'Confirmed',
        rejected: 'Rejected',
      }
    end

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('DND')} to confirm match success"
      when :confirmed then "#{_('DND')} confirms match success"
      when :rejected then "Match rejected by #{_('DND')}"
      end
    end

    def step_name
      _('Confirm Match Success')
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      nil
    end

    def editable?
      super && status !~ /confirmed|rejected/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      Notifications::ConfirmMatchSuccessDndStaff.create_for_match! match
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        # m << Notifications::RecordClientHousedDateHousingSubsidyAdministrator
        m << Notifications::MoveInDateSet # Sent to both HSA and Shelter Agency
        m << Notifications::ConfirmMatchSuccessDndStaff
      end
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def note_present_if_status_rejected
      if note.blank? && status == 'rejected'
        errors.add :note, 'Please note why the match is declined.'
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmedDevelopmentOfficer.create_for_match! match
        match.succeeded!
      end

      def rejected
        match.rejected!
      end
    end
    private_constant :StatusCallbacks

  end

end

