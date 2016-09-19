module MatchDecisions
  class ScheduleCriminalHearingHousingSubsidyAdmin < Base
    
    validate :criminal_hearing_date_present_if_scheduled
    validate :criminal_hearing_date_absent_if_no_hearing
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'Housing Subsidy Administrator researching criminal background and deciding whether to schedule a hearing'
      when :scheduled then "Housing Subsidy Administrator has scheduled criminal background hearing for #{criminal_hearing_date.try :strftime, '%m/%d/%Y'}"
      when :no_hearing then 'Housing Subsidy Administrator indicates there will not be a criminal background hearing'
      end
    end

    def step_name
      'Housing Subsidy Administrator Reviews Match'
    end

    def actor_type
      'HSA'
    end
    
    def statuses
      {pending: 'Pending', scheduled: 'Criminal Background Hearing Scheduled', no_hearing: 'There will not be a criminal background hearing'}
    end
    
    def editable?
      super && saved_status !~ /scheduled|no_hearing/
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::ScheduleCriminalHearingHousingSubsidyAdmin.create_for_match! match
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::ScheduleCriminalHearingHousingSubsidyAdmin
      end
    end
    
    def permitted_params
      super + [:criminal_hearing_date]
    end

    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def scheduled
        match.approve_match_housing_subsidy_admin_decision.initialize_decision!
        Notifications::CriminalHearingScheduledClient.create_for_match! match
        Notifications::CriminalHearingScheduledDndStaff.create_for_match! match
        Notifications::CriminalHearingScheduledShelterAgency.create_for_match! match
      end

      def no_hearing
        match.approve_match_housing_subsidy_admin_decision.initialize_decision!
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

