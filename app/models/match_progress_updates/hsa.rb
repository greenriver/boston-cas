###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
