###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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