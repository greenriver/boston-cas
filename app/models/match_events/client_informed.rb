###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchEvents
  class ClientInformed < Base
    def name
      'Client was informed of match status'
    end

    def contact_name
      match.client&.full_name
    end
  end
end
