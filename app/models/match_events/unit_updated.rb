###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class UnitUpdated < Base
    def name
      "Building and/or unit changed. #{note}"
    end
  end
end