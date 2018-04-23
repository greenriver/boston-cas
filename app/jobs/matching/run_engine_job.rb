module Matching
  class RunEngineJob < ActiveJob::Base
  
    def perform
      MatchRoutes::Base.all_routes.each do |route|
        Matching::Matchability.update(Opportunity.on_route(route), match_route: route)
        Matching::Engine.create_candidates(match_route: route)
      end
    end

  end
end