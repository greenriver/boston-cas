###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class MatchDecisionReasonAssignment < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  KIND_DECLINE = 'decline'
  KIND_CANCEL = 'cancel'
  KINDS = [KIND_DECLINE, KIND_CANCEL].freeze

  belongs_to :route, class_name: 'MatchRoutes::Base'
  belongs_to :match_decision_reason, class_name: 'MatchDecisionReasons::Base'

  validates :kind, inclusion: { in: KINDS }
  validates :decision_type, presence: true
  validates :audience, inclusion: { in: ->(assignment) { assignment.route&.visible_contact_types&.map(&:to_s) || [] }, allow_blank: true }
  validate :audience_only_on_steps_supporting_multiple_actors

  scope :ordered, -> { order(:position, :id) }
  scope :with_active_reason, -> { joins(:match_decision_reason).merge(MatchDecisionReasons::Base.active) }

  def self.resolve_for(route:, decision_type:, kind:)
    where(route: route, decision_type: decision_type, kind: kind).with_active_reason.ordered.to_a
  end

  private def audience_only_on_steps_supporting_multiple_actors
    return if audience.blank?

    if kind != KIND_DECLINE
      errors.add(:audience, 'is only applicable to decline reasons')
      return
    end

    decision_class = decision_type&.safe_constantize
    errors.add(:audience, 'is not applicable to this step') unless decision_class&.new&.supports_multiple_actors?
  end
end
