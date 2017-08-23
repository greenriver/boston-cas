module MatchDecisions
  class RecordClientHousedDateHousingSubsidyAdministrator < Base
    
    validate :client_move_in_date_present_if_status_complete
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator')} to note when client will move in."
      when :completed then "#{_('Housing Subsidy Administrator')} notes lease start date #{client_move_in_date.try :strftime, '%m/%d/%Y'}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      'Indicate date client was housed'
    end

    def actor_type
      "#{_('HSA')}"
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end
    
    def statuses
      {
        pending: 'Pending', 
        completed: 'Complete', 
        canceled: 'Canceled',
      }
    end
    
    def editable?
      super && saved_status !~ /complete/
    end
    
    def permitted_params
      super + [:client_move_in_date]
    end

    def initialize_decision!
      update status: 'pending'
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::HousingSubsidyAdminDecisionClient
        m << Notifications::HousingSubsidyAdminDecisionSsp
        m << Notifications::HousingSubsidyAdminAcceptedMatchDndStaff
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact:
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def completed
        match.confirm_match_success_dnd_staff_decision.initialize_decision!
        Notifications::MoveInDateSet.create_for_match! match
        # Notifications::RecordClientHousedDateHousingSubsidyAdministrator.create_for_match! match
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
    
    
    private def client_move_in_date_present_if_status_complete
      if status == 'completed' && client_move_in_date.blank?
        errors.add :client_move_in_date, 'must be filled in'
      end
    end
    
  end
  
end
