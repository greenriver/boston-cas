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
      end
    end

    def step_name
      'Indicate date client has been (or will be) housed'
    end

    def actor_type
      'Shelter Agency'
    end
    
    def statuses
      {pending: 'Pending', completed: 'Complete'}
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

    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff? ||
      contact.in?(match.shelter_agency_contacts)
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def completed
        match.confirm_match_success_dnd_staff_decision.initialize_decision!
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

