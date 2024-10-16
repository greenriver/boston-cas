###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Base < ApplicationRecord
    self.table_name = :match_routes
    serialize :prioritized_client_columns, Array
    serialize :routes_parked_on_active_match, Array
    serialize :routes_parked_on_successful_match, Array

    belongs_to :match_prioritization, class_name: 'MatchPrioritization::Base', foreign_key: :match_prioritization_id, primary_key: :id
    belongs_to :tag if column_names.include?('tag_id')
    has_many :weighting_rules, inverse_of: :route, foreign_key: :route_id

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
        MatchRoutes::Six,
        MatchRoutes::Seven,
        MatchRoutes::Eight,
        MatchRoutes::Nine,
        MatchRoutes::Ten,
        MatchRoutes::Eleven,
        MatchRoutes::Twelve,
        MatchRoutes::Thirteen,
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
        route.first_or_create(weight: i) do |r|
          r.active = false
          r.save
        end
      end
    end

    # implement in sub-classes
    def title
      raise NotImplementedError
    end

    def initial_decision
      raise NotImplementedError
    end

    def first_client_step
      self.class.match_steps.keys.first
    end

    def auto_initialize_event?
      true
    end

    # The number of the step in match_steps of the first step where a client interaction is required
    private def first_client_step_number
      self.class.match_steps_for_reporting[first_client_step]
    end

    def on_or_after_first_client_step?(current_decision)
      on_first_client_step?(current_decision) || after_first_client_step?(current_decision)
    end

    def on_first_client_step?(current_decision)
      return false unless self.class.match_steps_for_reporting[current_decision.class.name].present?

      self.class.match_steps_for_reporting[current_decision.class.name] == first_client_step_number
    end

    def after_first_client_step?(current_decision)
      return false unless self.class.match_steps_for_reporting[current_decision.class.name].present?

      self.class.match_steps_for_reporting[current_decision.class.name] > first_client_step_number
    end

    def success_decision
      raise NotImplementedError
    end

    def initial_contacts_for_match
      raise NotImplementedError
    end

    def removed_hsa_reasons
      []
    end

    def additional_hsa_reasons
      []
    end

    def removed_admin_reasons
      []
    end

    def additional_admin_reasons
      []
    end

    def show_hearing_date
      true
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
        Translation.translate('DND')
      when :housing_subsidy_admin_contacts
        Translation.translate('Housing Subsidy Administrator')
      when :client_contacts
        Translation.translate('Client')
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency')
      when :ssp_contacts
        Translation.translate('Stabilization Service Provider')
      when :hsp_contacts
        Translation.translate('Housing Search Provider')
      when :do_contacts
        Translation.translate('Development Officer')
      end
    end

    def visible_contact_types
      [
        :shelter_agency_contacts,
        :dnd_staff_contacts,
        :housing_subsidy_admin_contacts,
        :ssp_contacts,
        :hsp_contacts,
        :do_contacts,
      ]
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
        '10 days' => 10,
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

    def status_declined?(match)
      raise NotImplementedError
    end

    private def has_tag_if_prioritization_requires_it # rubocop:disable  Naming/PredicateName
      errors.add :tag_id, 'Chosen prioritization scheme requires a tag be set' if tag_id.blank? && match_prioritization&.requires_tag?
    end
  end
end
