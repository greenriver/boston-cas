class AddUniverseStateToPreviousMatches < ActiveRecord::Migration
  def up
    ClientOpportunityMatch.where(universe_state: nil).each do |match|
      universe_state = {
        requirements: match.opportunity.requirements_for_archive,
        services: match.opportunity.services_for_archive,
        opportunity: match.opportunity.opportunity_details.opportunity_for_archive,
        client: match.client.prepare_for_archive,
      }
      match.update_attribute(:universe_state, universe_state)
    end
  end
end