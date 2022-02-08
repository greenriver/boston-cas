###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class WeightingRule < ApplicationRecord
  include Matching::HasOrInheritsRequirements
  include HasRequirements

  belongs_to :route, class_name: 'MatchRoutes::Base'
  validates_presence_of :route

  acts_as_paranoid
  has_paper_trail

  scope :lightest_first, -> do
    order(applied_to: :asc)
  end

  scope :for_route, ->(route_id) do
    where(route_id: route_id)
  end

  def self.next_for(route_id)
    for_route(route_id).lightest_first.first
  end

  def self.reset_for(route_id)
    for_route(route_id).update_all(applied_to: 0)
  end

  def self.requirements_and_increment!(route)
    return unless route.weighting_rules.present?

    rule = next_for(route.id)
    rule.increment!
    rule.requirements.map(&:dup)
  end

  def increment!
    self.applied_to += 1
    save
  end

  def reset_similar_counts!
    self.class.reset_for(route_id)
  end

  def inherited_requirements_by_source
    {}
  end

  def self.preload_for_inherited_requirements
    all
  end

  def requirements_description
    requirements.map(&:name).compact.join ', '
  end

  def name
    'Match Route Weighting Rule'
  end
end
