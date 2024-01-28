###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class Base < Notifications::Base
    def match_route
      MatchRoutes::Five.new
    end
  end
end
