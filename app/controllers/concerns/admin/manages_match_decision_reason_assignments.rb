###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin::ManagesMatchDecisionReasonAssignments
  extend ActiveSupport::Concern

  ReasonRow = Struct.new(:reason, :assignment)

  private def sync_match_decision_reason_assignments!(route:, decision_type:, assignments_params:, kinds: ['decline', 'cancel'])
    kinds.each do |kind|
      sync_kind!(route: route, decision_type: decision_type, kind: kind, rows_params: assignments_params&.dig(kind))
    end
  end

  private def sync_kind!(route:, decision_type:, kind:, rows_params:)
    return if rows_params.nil?

    existing = MatchDecisionReasonAssignment.where(route: route, decision_type: decision_type, kind: kind).index_by(&:match_decision_reason_id)
    offered_reason_ids = MatchDecisionReasons::Base.active.ids

    rows_params.each do |reason_id, row|
      next unless row[:selected] == '1'

      reason_id = reason_id.to_i
      assignment = existing.delete(reason_id) || MatchDecisionReasonAssignment.new(route: route, decision_type: decision_type, kind: kind, match_decision_reason_id: reason_id)
      assignment.position = row[:position].presence || 0
      assignment.requires_explanation = row[:requires_explanation] == '1'
      assignment.referral_result = row[:referral_result].presence
      assignment.audience = row[:audience].presence
      assignment.save!
    end

    existing.each do |reason_id, assignment|
      assignment.destroy if offered_reason_ids.include?(reason_id)
    end
  end

  private def match_decision_reason_rows(route:, decision_type:)
    reasons = MatchDecisionReasons::Base.active.order(:name)
    existing_by_kind = MatchDecisionReasonAssignment.where(route: route, decision_type: decision_type).group_by(&:kind)

    {
      decline: build_rows(reasons, existing_by_kind['decline'] || []),
      cancel: build_rows(reasons, existing_by_kind['cancel'] || []),
    }
  end

  private def build_rows(reasons, assignments)
    by_reason_id = assignments.index_by(&:match_decision_reason_id)
    reasons.map { |reason| ReasonRow.new(reason, by_reason_id[reason.id]) }
  end
end
