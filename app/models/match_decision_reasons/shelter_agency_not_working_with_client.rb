###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class ShelterAgencyNotWorkingWithClient < Base
    def not_working_with_client?
      true
    end

    def title
      "#{_('Shelter Agency')} Not Working with Client"
    end
  end
end
