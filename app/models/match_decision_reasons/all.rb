###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# TODO: remove all non Base MatchDecisionReasons after release-63 is deployed to production
module MatchDecisionReasons
  class All < Base
    def title
      ''
    end
  end
end
