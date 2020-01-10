###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Matching::Engine
  class << self
    def for_available_clients(opportunities, match_route: )
      new(available_clients(match_route: match_route), opportunities)
    end

    def create_candidates match_route:
      new(available_clients(match_route: match_route), available_opportunities(match_route: match_route)).replace_candidates
    end

    def available_client_count match_route:
      available_clients(match_route: match_route).size
    end

    def available_clients match_route:
      # returns AR scope
      Client.available_for_matching(match_route)
    end

    def available_opportunities match_route:
      # returns AR scope
      # Need to require a voucher or else we end up with very odd situations
      Opportunity.with_voucher.available_candidate.on_route(match_route)
    end

  end

  attr_reader :clients, :opportunities

  def initialize(clients, opportunities)
    @clients = clients
    @opportunities = opportunities
  end

  def replace_candidates
    destroy_candidates && create_candidates
  end

  def destroy_candidates
    [opportunities].each do |candidates|
      candidates.each do |candidate|
        candidate.candidate_matches.proposed.delete_all
      end
    end
  end

  def create_candidates
    prioritized_candidate_opportunities.each do |opportunity|
      create_candidate_matches(opportunity)
    end
  end

  def batch_loaded(relation, batch_size)
    # find_in_batches is interfering with a scope that is using a limit, because
    # it adds its own limit, which just overrides the first one. I should just
    # make my own custom batch finder (or remove this one for now...)
    relation.find_in_batches(batch_size: batch_size).each do |batch|
      batch.each {|item| yield item}
    end
  end

  def create_candidate_matches(opportunity)
    matches_left_to_max = opportunity.matches_left_to_max
    client_priority = 1
    clients_for_matches(opportunity).each do |client|
      universe_state = {
        requirements: opportunity.requirements_for_archive,
        services: opportunity.services_for_archive,
        opportunity: opportunity.opportunity_details.opportunity_for_archive,
        client: client.prepare_for_archive,
      }
      match = client.candidate_matches.create(opportunity: opportunity,
        client: client,
        match_route: opportunity.match_route,
        universe_state: universe_state)

      if client_priority == 1
        if opportunity.match_route.should_activate_match
          match.activate!
        else
          match.matched!
        end
      end

      client_priority += 1
    end

    matches_left_to_max - opportunity.matches_left_to_max
  end

  def clients_for_matches opportunity
    client_scope = prioritized_candidate_clients(match_route: opportunity.match_route)
    # take into account unit attributes
    client_scope = opportunity.add_unit_attributes_filter(client_scope)

    opportunity.matching_co_candidates_for_max(client_scope)

  end

  def prioritized_candidate_opportunities
    @_prioritized_candidate_opportunities ||= opportunity_candidates(opportunities).order(:matchability)
  end

  def prioritized_candidate_clients match_route:
    @_prioritized_candidate_clients = Client.prioritized(match_route, client_candidates(clients, match_route: match_route))
  end

  def opportunity_candidates subjects
    subjects.ready_to_match.eager_load(:candidate_matches)
  end

  def client_candidates subjects, match_route:
    subjects.ready_to_match(match_route: match_route).eager_load(:candidate_matches)
  end
end
