###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class Base < Notifications::Base
    def match_route
      MatchRoutes::Five.new
    end
  end
end
