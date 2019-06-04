###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class Parked < Base
    def name
      'Match canceled, client was parked'
    end
  end
end