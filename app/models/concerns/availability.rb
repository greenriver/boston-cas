# Tools for ensuring client availability
module Availability
  extend ActiveSupport::Concern
  included do
    def self.ensure_availability
      available.each(&:ensure_availability)
    end

    def ensure_availability
      self.class.transaction do
        unavailable_as_candidate_fors.destroy_all
        unavailable_routes.each do |route|
          make_unavailable_in match_route: route
        end
      end
    end

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
  end
end
