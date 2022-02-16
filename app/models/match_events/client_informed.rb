###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchEvents
  class ClientInformed < Base
    def name
      'Client was informed of match status'
    end

    def contact_name
      'Client'
    end
  end
end
