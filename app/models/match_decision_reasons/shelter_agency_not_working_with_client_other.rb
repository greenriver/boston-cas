###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchDecisionReasons
  class ShelterAgencyNotWorkingWithClientOther < Base

    def other?
      true
    end

    def not_working_with_client?
      true
    end

  end
end