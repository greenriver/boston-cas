###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchEvents
  class Parked < Base
    def name
      'Match canceled, client was parked'
    end
  end
end
