module Notifications
  class ScheduleCriminalHearingSsp < Base
    
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      'Stabilization Service Provider was sent full details of match for review'
    end
    
  end
end
