module MatchDecisions
  class ScheduleCriminalHearingHousingSubsidyAdmin < Base
    
    validate :criminal_hearing_date_present_if_scheduled
    validate :criminal_hearing_date_absent_if_no_hearing
   
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator')} #{_('researching criminal background and deciding whether to schedule a hearing')}"
      when :scheduled then "#{_('Housing Subsidy Administrator')} #{_('has scheduled criminal background hearing for')} <strong>#{criminal_hearing_date}</strong>".html_safe
      when :no_hearing then "#{_('Housing Subsidy Administrator')} #{_('indicates there will not be a criminal background hearing')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      "#{_('Housing Subsidy Administrator')} Reviews Match"
    end

    def actor_type
      _('HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end
    
    def statuses
      {
        pending: 'Pending', 
        scheduled: _('Criminal Background Hearing Scheduled'), 
        no_hearing: _('There will not be a criminal background hearing'), 
        canceled: 'Canceled',
        back: 'Pending',
      }
    end
    
    def editable?
      super && saved_status !~ /scheduled|no_hearing/
    end

    def initialize_decision! send_notifications: true
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::ScheduleCriminalHearingHousingSubsidyAdmin
        m << Notifications::ScheduleCriminalHearingSsp
        m << Notifications::ScheduleCriminalHearingHsp
        m << Notifications::ShelterAgencyAccepted
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact:
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end
    
    def permitted_params
      super + [:criminal_hearing_date]
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def scheduled
        @decision.next_step.initialize_decision!
      end

      def no_hearing
        # Set the next step status to approved and skip the next step
        @decision.next_step.update(status: :accepted)
        @decision.next_step.next_step.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private
      
      def criminal_hearing_date_present_if_scheduled
        if status == 'scheduled' && criminal_hearing_date.blank?
          errors.add :criminal_hearing_date, 'must be filled in'
        end
      end

      def criminal_hearing_date_absent_if_no_hearing
        if status == 'no_hearing' && criminal_hearing_date.present?
          errors.add :criminal_hearing_date, 'must not be filled in'
        end
      end
    
  end  
end

