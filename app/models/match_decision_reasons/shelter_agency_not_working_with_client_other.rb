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
