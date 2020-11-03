###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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