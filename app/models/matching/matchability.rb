###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Matching
  class Matchability
    def initialize(opportunity, engine, available_clients_on_route_count)
      @opportunity = opportunity
      @engine = engine
      @available_clients_on_route_count = available_clients_on_route_count
    end

    def self.update(opportunities, match_route:)
      engine = Engine.for_available_clients(opportunities, match_route: match_route)
      clients_on_route = available_clients_on_route_count(match_route)
      opportunities.each do |opportunity|
        new(opportunity, engine, clients_on_route).update
      end
    end

    def self.available_clients_on_route_count match_route
      Matching::Engine.available_client_count(match_route: match_route)
    end

    def update
      @opportunity.update_attribute(:matchability, current_value) if @opportunity.matchability != current_value
    end

    private def current_value
      matching_client_count.to_f / @available_clients_on_route_count
    end

    private def matching_client_count
      @opportunity.matching_co_candidates(Client.all).count
    end
  end
end
