###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchEvents
  class UnitUpdated < Base
    def name
      "Building and/or unit changed. #{note}"
    end
  end
end
