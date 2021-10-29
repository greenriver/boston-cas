###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class ShelterAgencyNotWorkingWithClientOther < Base
    def other?
      true
    end

    def not_working_with_client?
      true
    end

    def title
      "#{_('Shelter Agency')} Not Working with Client Other"
    end
  end
end
