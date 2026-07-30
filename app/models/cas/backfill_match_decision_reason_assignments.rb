###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Cas
  class BackfillMatchDecisionReasonAssignments
    # MatchDecisions::Base#step_cancel_reasons has already been rewritten (elsewhere in this migration) to read
    # from the very tables this task is populating. For a decision class that never overrode step_cancel_reasons,
    # calling it here would read back today's (empty) DB state instead of the original hardcoded list it used to
    # return, so that original list is preserved here instead.
    DEFAULT_CANCEL_REASONS = [
      'Match expired',
      'Client has declined match',
      'Client has disengaged',
      'Client has disappeared',
      'SSP CORI',
      'HSP CORI',
      'Incarcerated',
      'Vacancy should not have been entered',
      'Client received another housing opportunity',
      'Client no longer eligible for match',
      'Client deceased',
      'Vacancy filled by other client',
      'Other',
    ].freeze

    def run!
      MatchRoutes::Base.ensure_all
      MatchRoutes::Base.all_routes.each do |route_class|
        route = route_class.first
        next unless route

        route_class.match_steps.each_key { |decision_type| backfill_step(route: route, decision_type: decision_type) }
      end
    end

    def backfill_step(route:, decision_type:)
      decision_class = decision_type.safe_constantize
      return unless decision_class

      decision = decision_class.new
      MatchDecisionStep.find_or_create_by!(route: route, decision_type: decision_type)

      if decision.respond_to?(:step_decline_reasons)
        backfill_kind(
          route: route,
          decision_type: decision_type,
          kind: 'decline',
          names: decision.step_decline_reasons(nil),
          requiring_explanation_names: decision.decline_reasons_not_other_requiring_explanation(nil),
        )
      end

      backfill_kind(
        route: route,
        decision_type: decision_type,
        kind: 'cancel',
        names: cancel_reason_names(decision),
        # cancel_reasons_not_other_requiring_explanation is only ever defined on MatchDecisions::Base itself
        # (never overridden), and was always an empty default, so there's nothing to read back for it.
        requiring_explanation_names: [],
      )
    rescue StandardError => e
      Rails.logger.warn("Skipping decision reason backfill for #{decision_type} on #{route.class.name}: #{e.message}")
    end

    private def cancel_reason_names(decision)
      return DEFAULT_CANCEL_REASONS if decision.method(:step_cancel_reasons).owner == MatchDecisions::Base

      decision.step_cancel_reasons
    end

    private def backfill_kind(route:, decision_type:, kind:, names:, requiring_explanation_names:)
      return if names.blank?

      sorted_names = names.uniq.sort_by { |name| [name.downcase == 'other' ? 1 : 0, name.downcase] }
      sorted_names.each_with_index do |name, index|
        reason = MatchDecisionReasons::Base.find_by(name: name)
        next unless reason

        MatchDecisionReasonAssignment.find_or_create_by!(route: route, decision_type: decision_type, match_decision_reason: reason, kind: kind) do |assignment|
          assignment.position = index
          assignment.requires_explanation = requiring_explanation_names.include?(name)
        end
      end
    end
  end
end
