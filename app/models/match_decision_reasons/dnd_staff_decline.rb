###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class DndStaffDecline < Base
    def title
      "#{Translation.translate('DND')} #{Translation.translate('Staff Decline')}"
    end
  end
end
