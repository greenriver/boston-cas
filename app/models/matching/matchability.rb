module Matching
  class Matchability
    def self.update(opportunities)
      engine = Engine.for_available_clients(opportunities)
      opportunities.each {|opportunity| new(opportunity, engine).update}
    end

    def initialize(opportunity, engine)
      @opportunity = opportunity
      @engine = engine
    end

    def update
      @opportunity.update_attribute(:matchability, current_value)
    end

    def current_value
      matching_client_count.to_f / Matching::Engine.available_client_count
    end

    def matching_client_count
      @opportunity.matching_co_candidates(Client.all).count
    end
  end
end
