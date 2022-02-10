###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class ShelterAgencyDecline < Base
    def title
      "#{_('Shelter Agency')} Decline"
    end
  end
end
