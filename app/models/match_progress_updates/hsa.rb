###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchProgressUpdates
  class Hsa < Base

    def name
      _('Housing Subsidy Administrator status update')
    end

    def self.match_contact_scope
      :housing_subsidy_admin_contacts
    end
  end
end
