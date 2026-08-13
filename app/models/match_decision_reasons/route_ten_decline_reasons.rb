###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisionReasons
  class RouteTenDeclineReasons < Base
    def title
      "#{Translation.translate('Route Ten')} Decline"
    end
  end
end
