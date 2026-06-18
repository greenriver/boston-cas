###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

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
