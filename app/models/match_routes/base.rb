module MatchRoutes
  class Base < ActiveRecord::Base
    self.table_name = :match_routes

    belongs_to :match_prioritization, class_name: MatchPrioritization::Base.name, foreign_key: :match_prioritization_id, primary_key: :id
    belongs_to :tag

    scope :available, -> do
      where(active: true).
        order(weight: :asc)
    end

    scope :should_cancel_other_matches, -> do
      where(should_cancel_other_matches: true)
    end

    validate :has_tag_if_prioritization_requires_it

    def self.all_routes
      [
        MatchRoutes::Default,
        MatchRoutes::ProviderOnly,
        MatchRoutes::HomelessSetAside,
      ]
    end

    def self.route_name_from_route route
      # route can be an instance or a class
      if route.class == Class
        route_name = route.name
      elsif MatchRoutes::Base.all_routes.include?(route.class)
        route_name = route.class.name
      else
        raise "Unknown route type passed #{route.inspect}"
      end
    end

    def self.more_than_one?
      available.count > 1
    end

    def self.filterable_routes
      available.map{|r| [r.title, r.type]}.to_h
    end

    def self.ensure_all
      all_routes.each_with_index do |route, i|
        route.first_or_create(weight: i)
      end
    end

    # implement in sub-classes
    def title
      raise NotImplementedError
    end

    def initial_decision
      raise NotImplementedError
    end

    def initial_contacts_for_match
      raise NotImplementedError
    end

    def self.match_steps
      all_routes.map do |route|
        [route.name, route.match_steps]
      end.to_h
    end

    def self.match_steps_for_reporting
      all_routes.map(&:match_steps_for_reporting).flatten().uniq.to_h
    end

    def self.available_sub_types_for_search
      all_routes.map(&:available_sub_types_for_search).flatten().uniq
    end

    def self.filter_options
      self.available_sub_types_for_search + self.stalled_match_filter_options
    end

    def self.stalled_match_filter_options
      ['Stalled Matches - awaiting response']
    end

    def self.max_matches_per_client
      6
    end

    def self.max_matches_per_opportunity
      20
    end

    def required_contact_types
      [
        'shelter_agency',
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    private def has_tag_if_prioritization_requires_it
      if tag_id.blank? && match_prioritization&.requires_tag?

        errors.add :tag_id, "Chosen prioritization scheme requires a tag be set"
      end
    end
  end
end
