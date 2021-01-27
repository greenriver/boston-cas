###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
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
