###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

###
# Shared helpers for admin screens that configure which match-decision reasons
# (decline/cancel) are available on a given route + decision step.
#
# Form submissions are treated as a full replacement of the offered set: selected
# rows are upserted; previously assigned rows that were unchecked are removed.
# Assignments for inactive reasons are left alone so historical configuration is
# not silently wiped when a reason is deactivated.
###
module Admin::ManagesMatchDecisionReasonAssignments
  extend ActiveSupport::Concern

  # Pairs an active reason with its assignment for the admin checklist UI.
  ReasonRow = Struct.new(:reason, :assignment)

  # Persists decline/cancel reason assignments from nested form params for a
  # route + decision_type. +kinds+ defaults to both decline and cancel; pass a
  # subset when a step only manages one kind.
  private def sync_match_decision_reason_assignments!(route:, decision_type:, assignments_params:, kinds: ['decline', 'cancel'])
    kinds.each do |kind|
      sync_kind!(route: route, decision_type: decision_type, kind: kind, rows_params: assignments_params&.dig(kind))
    end
  end

  # Upserts selected rows for one kind and destroys unchecked assignments whose
  # reasons are still active. Skips entirely when that kind's params are absent
  # so a form that omits a kind does not clear its assignments.
  private def sync_kind!(route:, decision_type:, kind:, rows_params:)
    return if rows_params.nil?

    existing = MatchDecisionReasonAssignment.where(route: route, decision_type: decision_type, kind: kind).index_by(&:match_decision_reason_id)
    offered_reason_ids = MatchDecisionReasons::Base.active.ids

    rows_params.each do |reason_id, row|
      next unless row[:selected] == '1'

      reason_id = reason_id.to_i
      # Remove from the existing hash so it isn't deleted below
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

  # Builds decline/cancel ReasonRow collections for the edit form: every active
  # reason, with its existing assignment when one is already configured.
  private def match_decision_reason_rows(route:, decision_type:)
    reasons = MatchDecisionReasons::Base.active.order(:name)
    existing_by_kind = MatchDecisionReasonAssignment.where(route: route, decision_type: decision_type).group_by(&:kind)

    {
      decline: build_rows(reasons, existing_by_kind['decline'] || []),
      cancel: build_rows(reasons, existing_by_kind['cancel'] || []),
    }
  end

  # One ReasonRow per reason; +assignment+ is nil when that reason is not yet
  # selected for this kind.
  private def build_rows(reasons, assignments)
    by_reason_id = assignments.index_by(&:match_decision_reason_id)
    reasons.map { |reason| ReasonRow.new(reason, by_reason_id[reason.id]) }
  end
end
