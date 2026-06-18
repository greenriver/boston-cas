###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisionReasons
  class RouteTwelveDeclineReasons < Base
    def title
      "#{Translation.translate('Route Twelve')} Decline"
    end
  end
end
