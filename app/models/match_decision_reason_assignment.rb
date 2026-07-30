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
  validates :decision_type, presence: true

  scope :ordered, -> { order(:position, :id) }
  scope :with_active_reason, -> { joins(:match_decision_reason).merge(MatchDecisionReasons::Base.active) }

  def self.resolve_for(route:, decision_type:, kind:)
    where(route: route, decision_type: decision_type, kind: kind).with_active_reason.ordered.to_a
  end
end
