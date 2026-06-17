###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchProgressUpdates
  class Anyone < Base
    validates_presence_of :response, :client_last_seen
    def name
      Translation.translate('Match status update')
    end

    def self.match_contact_scope
      :client_opportunity_match_contacts
    end
  end
end
