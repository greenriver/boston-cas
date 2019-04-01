module MatchProgressUpdates
  class Ssp < Base
    def name
      'Stabilization Service Provider status update'
    end

    def self.match_contact_scope
      :ssp_contacts
    end
  end
end
