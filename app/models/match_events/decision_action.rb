module MatchEvents
  class DecisionAction < Base
    
    def name
      decision_name = decision.label_for_status self.action
      if not_working_with_client_reason.present? 
        decision_name << "; no longer working with client: #{not_working_with_client_reason.name}"
      end
      if client_last_seen_date.present? 
        decision_name << "; last seen: #{client_last_seen_date}"
      end
      decision_name
    end

  end
end