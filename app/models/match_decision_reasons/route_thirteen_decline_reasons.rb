###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisionReasons
  class RouteThirteenDeclineReasons < Base
    def title
      "#{Translation.translate('Route Thirteen')} Decline"
    end
  end
end
