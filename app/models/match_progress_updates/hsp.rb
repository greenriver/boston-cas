###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

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
