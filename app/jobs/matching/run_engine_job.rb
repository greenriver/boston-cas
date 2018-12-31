module Matching
  class RunEngineJob < BaseJob

    def perform
      # prevent the engine from running simultaneously
      ClientOpportunityMatch.with_advisory_lock(:engine_lock) do
        # TODO replaced all_routes with available -- this means inactive routes will not be run, I believe this was the intended behavior, anyway?
        MatchRoutes::Base.available.each do |route|
          Matching::Matchability.update(Opportunity.on_route(route), match_route: route)
          Matching::Engine.create_candidates(match_route: route)
        end
      end
    end
  end
end