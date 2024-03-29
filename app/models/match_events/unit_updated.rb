###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchEvents
  class UnitUpdated < Base
    def name
      "Building and/or unit changed. #{note}"
    end
  end
end
