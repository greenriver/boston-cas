module Notifications
  class MatchInitiationForManualNotification < Notifications::Base

    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} notified of manual match"
    end
  end
end