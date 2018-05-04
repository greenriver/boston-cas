module Matching
  class RunEngineJob < ActiveJob::Base
  
    def perform
      # prevent the engine from running simultaneously
      ClientOpportunityMatch.with_advisory_lock(:engine_lock) do
        Matching::Matchability.update Opportunity.all
        Matching::Engine.create_candidates
      end
    end

  end
end