module MatchProgressUpdates
  class Hsp < Base
    
    def name
      'Housing Search Provider status update'
    end

    def self.match_contact_scope
      :hsp_contacts
    end
  end
end