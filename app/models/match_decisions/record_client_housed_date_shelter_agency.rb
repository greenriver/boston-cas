module MatchDecisions
  class RecordClientHousedDateShelterAgency < Base
    
    validate :client_move_in_date_present_if_status_complete
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'Shelter Agency to note when client will move in.'
      when :completed then "Shelter Agency notes client will move in #{client_move_in_date.try :strftime, '%m/%d/%Y'}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      'Indicate date client has been (or will be) housed'
    end

    def actor_type
      'Shelter Agency'
    end

    def contact_actor_type
      :shelter_agency_contacts
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
      Notifications::RecordClientHousedDateShelterAgency.create_for_match! match
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::HousingSubsidyAdminDecisionClient
        m << Notifications::HousingSubsidyAdminAcceptedMatchDndStaff
        m << Notifications::RecordClientHousedDateShelterAgency
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact:
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.shelter_agency_contacts)
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def completed
        match.confirm_match_success_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
    
    private
    
      def client_move_in_date_present_if_status_complete
        if status == 'complete' && client_move_in_date.blank?
          errors.add :client_move_in_date, 'must be filled in'
        end
      end
    
  end
  
end

