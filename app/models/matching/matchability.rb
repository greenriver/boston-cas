module Matching
  class Matchability
    def self.update(opportunities, match_route:)
      engine = Engine.for_available_clients(opportunities, match_route: match_route)
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
      matching_client_count.to_f / Matching::Engine.available_client_count(match_route: @opportunity.match_route)
    end

    def matching_client_count
      @opportunity.matching_co_candidates(Client.all).count
    end
  end
end
