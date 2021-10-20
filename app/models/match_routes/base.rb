###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Base < ApplicationRecord
    self.table_name = :match_routes

    belongs_to :match_prioritization, class_name: MatchPrioritization::Base.name, foreign_key: :match_prioritization_id, primary_key: :id
    belongs_to :tag if column_names.include?('tag_id')

    scope :active, -> do
      where(active: true)
    end

    scope :available, -> do
      where(active: true).
        order(weight: :asc)
    end

    scope :should_cancel_other_matches, -> do
      where(should_cancel_other_matches: true)
    end

    validate :has_tag_if_prioritization_requires_it if column_names.include?('tag_id')

    def self.all_routes
      [
        MatchRoutes::Default,
        MatchRoutes::ProviderOnly,
        MatchRoutes::HomelessSetAside,
        MatchRoutes::Four,
        MatchRoutes::Five,
      ]
    end

    def self.route_name_from_route route
      # route can be an instance or a class
      return route.name if route.instance_of?(Class)
      return route.class.name if MatchRoutes::Base.all_routes.include?(route.class)

      raise "Unknown route type passed #{route.inspect}"
    end

    def self.more_than_one?
      available.count > 1
    end

    def self.filterable_routes
      available.map { |r| [r.title, r.type] }.to_h
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

    def success_decision
      raise NotImplementedError
    end

    def initial_contacts_for_match
      raise NotImplementedError
    end

    def removed_admin_reasons
      nil
    end

    def additional_admin_reasons
      nil
    end

    def self.match_steps
      all_routes.map do |route|
        [route.name, route.match_steps]
      end.to_h
    end

    def self.match_steps_for_reporting
      all_routes.map(&:match_steps_for_reporting).flatten.uniq.to_h
    end

    def self.available_sub_types_for_search
      all_routes.map(&:available_sub_types_for_search).flatten.uniq
    end

    def self.filter_options
      available_sub_types_for_search + stalled_match_filter_options
    end

    def self.stalled_match_filter_options
      ['Stalled Matches - awaiting response']
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        _('DND')
      when :housing_subsidy_admin_contacts
        _('Housing Subsidy Administrator')
      when :client_contacts
        _('Client')
      when :shelter_agency_contacts
        _('Shelter Agency')
      when :ssp_contacts
        _('Stabilization Service Provider')
      when :hsp_contacts
        _('Housing Search Provider')
      when :do_contacts
        _('Development Officer')
      end
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

    def stall_intervals
      {
        'No stalled notifications' => 0,
        '7 days' => 7,
        '14 days' => 14,
        '30 days' => 30,
      }
    end

    def housing_types
      [
        'RRH',
        'PSH',
      ]
    end

    def default_program_type
      'Project-Based'
    end

    private def has_tag_if_prioritization_requires_it # rubocop:disable  Naming/PredicateName
      errors.add :tag_id, 'Chosen prioritization scheme requires a tag be set' if tag_id.blank? && match_prioritization&.requires_tag?
    end
  end
end
