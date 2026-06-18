###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
