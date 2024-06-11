###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# Tools for ensuring client availability
module Availability
  extend ActiveSupport::Concern

  included do
    # any routes with active or successful matches
    def unavailable_routes
      (active_routes + successful_routes).uniq
    end

    def active_routes
      client_opportunity_matches.active.map(&:match_route).uniq
    end

    def successful_routes
      client_opportunity_matches.success.map(&:match_route).uniq
    end

    def available_as_candidate_for_any_route?
      (
        MatchRoutes::Base.available.pluck(:type) -
        UnavailableAsCandidateFor.where(client_id: id).distinct.pluck(:match_route_type)
      ).any?
    end

    def make_available_in(match_route:)
      route_name = MatchRoutes::Base.route_name_from_route(match_route)
      UnavailableAsCandidateFor.where(client_id: id, match_route_type: route_name).destroy_all
    end

    def make_available_in_all_routes
      UnavailableAsCandidateFor.where(client_id: id).destroy_all
    end

    def make_unavailable_in(match_route:, user:, reason:, expires_at: default_unavailable_expiration_date, match: nil)
      route_name = MatchRoutes::Base.route_name_from_route(match_route)

      # Delete any previous unavailable_as_candidate_fors so we can track the reason for this one
      unavailable_as_candidate_fors.where(match_route_type: route_name).each(&:desroy!)

      unavailable_as_candidate_fors.where(match_route_type: route_name).create!(
        expires_at: expires_at,
        user_id: user&.id,
        reason: reason,
        match: match,
      )
    end

    def make_unavailable_in_all_routes(user:, reason:, expires_at: default_unavailable_expiration_date, match: nil)
      MatchRoutes::Base.all_routes.each do |route|
        make_unavailable_in(match_route: route, expires_at: expires_at, user: user, reason: reason, match: match)
      end
    end

    # cancel_specific must be a match object
    def unavailable( # rubocop:disable Metrics/ParameterLists
      permanent: false,
      contact_id: nil,
      cancel_all: false,
      cancel_specific: false,
      expires_at: default_unavailable_expiration_date,
      user: nil,
      match: nil
    )
      Client.transaction do
        update!(available: false) if permanent

        if cancel_all
          # Cancel any active matches
          client_opportunity_matches.active.each do |active_match|
            opportunity = active_match.opportunity
            active_match.canceled!
            MatchEvents::Parked.create!(
              match_id: active_match.id,
              contact_id: contact_id,
            )
            opportunity.update!(available_candidate: true)
          end
          # Delete any non-active open matches
          client_opportunity_matches.open.each(&:delete)
          # Prevent any new matches for this client
          # This will re-queue the client once the date is passed
          make_unavailable_in_all_routes(expires_at: expires_at, user: user, match: match, reason: 'Parked')
        end

        if cancel_specific
          # remove from specific match and proposed on same route
          match = cancel_specific
          opportunity = match.opportunity
          route = match.match_route
          match.canceled! # note canceled! makes the client available in the route
          Notifications::MatchCanceled.create_for_match! match
          MatchEvents::Parked.create!(
            match_id: match.id,
            contact_id: contact_id,
          )
          opportunity.update(available_candidate: true)
          # Delete any non-active open matches
          client_opportunity_matches.on_route(route).proposed.each(&:delete)
          make_unavailable_in(match_route: route, expires_at: expires_at, user: user, match: match, reason: 'Parked')
        end
      end
      Matching::RunEngineJob.perform_later
    end

    private def default_unavailable_expiration_date
      days = Config.get(:unavailable_for_length)
      return nil unless days.present? && days.positive?

      Date.current + days.days
    end
  end
end
