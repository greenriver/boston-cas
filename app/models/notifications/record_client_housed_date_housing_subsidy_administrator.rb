module Notifications
  class RecordClientHousedDateHousingSubsidyAdministrator < Base
    
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end
    
    def decision
      match.record_client_housed_date_housing_subsidy_administrator_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} notified of approved match and asked to record lease start date"
    end

  end
end
