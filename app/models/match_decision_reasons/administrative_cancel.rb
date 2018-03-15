module MatchDecisionReasons
  class AdministrativeCancel < Base

    def self.available
      @availble ||= active.to_a << MatchDecisionReasons::Other.first 
    end
  end
end