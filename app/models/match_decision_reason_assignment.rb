###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class MatchDecisionReasonAssignment < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :route, class_name: 'MatchRoutes::Base'
  belongs_to :match_decision_reason, class_name: 'MatchDecisionReasons::Base'

  validates :kind, inclusion: { in: ['decline', 'cancel'] }

  scope :ordered, -> { order(:position, :id) }
  scope :route_level, -> { where(decision_type: '') }
  scope :with_active_reason, -> { joins(:match_decision_reason).merge(MatchDecisionReasons::Base.active) }

  def self.resolve_for(route:, decision_type:, kind:)
    step_scope = where(route: route, decision_type: decision_type, kind: kind)
    return step_scope.with_active_reason.ordered.to_a if step_scope.exists?

    where(route: route, kind: kind).route_level.with_active_reason.ordered.to_a
  end
end
