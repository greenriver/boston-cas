###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class DndStaffDecline < Base
    def title
      "#{_('DND')} #{_('Staff Decline')}"
    end
  end
end
