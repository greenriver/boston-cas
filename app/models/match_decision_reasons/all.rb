###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# TODO: remove all non Base MatchDecisionReasons after release-63 is deployed to production
module MatchDecisionReasons
  class All < Base
    def title
      ''
    end
  end
end
