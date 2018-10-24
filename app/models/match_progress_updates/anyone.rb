module MatchProgressUpdates
  class Anyone < Base
    validates_presence_of :response, :client_last_seen
    def name
      _('Match status update')
    end

    def self.match_contact_scope
      :client_opportunity_match_contacts
    end
  end
end