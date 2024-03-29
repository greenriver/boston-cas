###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchProgressUpdates
  class Hsa < Base

    def name
      Translation.translate('Housing Subsidy Administrator status update')
    end

    def self.match_contact_scope
      :housing_subsidy_admin_contacts
    end
  end
end
