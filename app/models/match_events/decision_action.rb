module MatchEvents
  class DecisionAction < Base
    
    def name
      decision.label_for_status self.action
    end

  end
end