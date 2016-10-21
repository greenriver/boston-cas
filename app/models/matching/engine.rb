class Matching::Engine
  class << self
    def for_available_clients(opportunities)
      new(available_clients, opportunities)
    end

    def create_candidates
      new(available_clients, available_opportunities).replace_candidates
    end

    def available_client_count
      available_clients.size
    end

    def available_clients
      # returns AR scope
      Client.where(available_candidate: true).where(['prevent_matching_until is null or prevent_matching_until < ?', Date.today])
    end

    def available_opportunities
      # returns AR scope
      Opportunity.where(available_candidate: true)
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
      match =
        client.candidate_matches.create(opportunity: opportunity, client: client, universe_state: universe_state)
      match.activate! if client_priority == 1
      client_priority += 1
    end

    matches_left_to_max - opportunity.matches_left_to_max
  end

  def clients_for_matches(opportunity)
    opportunity.matching_co_candidates_for_max(prioritized_candidate_clients)
  end

  def prioritized_candidate_opportunities
    @_prioritized_candidate_opportunities ||= candidates(opportunities).order(:matchability)
  end

  def prioritized_candidate_clients
    @_prioritized_candidate_clients ||= candidates(clients).prioritized
  end

  def candidates(subjects)
    subjects.ready_to_match.eager_load(:candidate_matches)
  end
end