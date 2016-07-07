module Matching
  class RunEngineJob < ActiveJob::Base
  
    def perform
      Matching::Matchability.update Opportunity.all
      Matching::Engine.create_candidates
    end

  end
end