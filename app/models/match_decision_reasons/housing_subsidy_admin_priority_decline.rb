###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class HousingSubsidyAdminPriorityDecline < Base
    def title
      "#{_('HSA')} Priority Decline"
    end
  end
end
