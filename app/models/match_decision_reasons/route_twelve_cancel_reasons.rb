###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class RouteTwelveCancelReasons < Base
    def title
      "#{Translation.translate('Route Twelve')} Cancel"
    end
  end
end
