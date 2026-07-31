###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions
  module AcceptsDeclineReason
    extend ActiveSupport::Concern

    included do
      validate :validate_decline_reason
      before_save :snapshot_decline_reason_text
    end

    def decline_reason_assignments(contact = nil)
      assignments = MatchDecisionReasonAssignment.resolve_for(route: match_route, decision_type: self.class.name, kind: MatchDecisionReasonAssignment::KIND_DECLINE)
      filter_reason_assignments_by_audience(assignments, contact)
    end

    def step_decline_reasons(contact = nil)
      decline_reason_assignments(contact).map { |assignment| assignment.match_decision_reason.name }
    end

    def decline_reasons(contact:)
      @decline_reasons ||= begin
        assignments = decline_reason_assignments(contact)
        non_other = assignments.reject { |assignment| assignment.match_decision_reason.other? }
        more_than_other_requires_explanation = non_other.any?(&:requires_explanation)
        all_require_explanation = all_declines_require_explanation(contact)

        assignments.map do |assignment|
          reason = assignment.match_decision_reason
          # Only include the asterisks if more than 'Other' requires additional explanation && if not ALL decline reasons require additional explanation
          include_asterisk = if all_require_explanation
            false
          elsif more_than_other_requires_explanation && (reason.other? || assignment.requires_explanation)
            true
          end

          name = reason.name
          name += '*' if include_asterisk
          [name, reason.id]
        end
      end
    end

    def all_declines_require_explanation(contact)
      non_other = decline_reason_assignments(contact).reject { |assignment| assignment.match_decision_reason.other? }
      non_other.present? && non_other.all?(&:requires_explanation)
    end

    def decline_reasons_not_other_requiring_explanation(contact = nil)
      decline_reason_assignments(contact).select(&:requires_explanation).map { |assignment| assignment.match_decision_reason.name }
    end

    def whitelist_params_for_update params
      result = super
      reason_id_array = Array.wrap params.require(:decision)[:decline_reason_id]
      decline_reason_id = reason_id_array.select(&:present?).first
      result.merge! decline_reason_id: decline_reason_id

      result.merge! params.require(:decision).permit(:decline_reason_other_explanation)
      return result
    end

    private def validate_decline_reason
      errors.add :decline_reason, ' is required when declining a match, please indicate the reason for declining' if status == 'declined' && decline_reason_blank? || (status == 'shelter_declined' && decline_reason_other_explanation.blank?)

      explanation_field_required = status == 'declined' && (decline_reason&.other? || decline_reasons_not_other_requiring_explanation&.include?(decline_reason&.name))
      explanation_field_required ||= status == 'shelter_declined' && (decline_reason&.other? || decline_reasons_not_other_requiring_explanation&.include?(decline_reason&.name))

      return unless explanation_field_required && decline_reason_other_explanation.blank?

      # Current contact is unknown in this context
      if all_declines_require_explanation(nil)
        errors.add :base, 'Decline reason details must be provided for the selection of any decline reason'
      else
        errors.add :decline_reason_other_explanation, "must be filled in if choosing '#{decline_reason&.name}'"
      end
    end

    private def decline_reason_blank?
      decline_reason.blank?
    end

    def decline_reason_name
      if decline_reason.blank?
        'none given'
      elsif decline_reason.other?
        "Other (#{decline_reason_other_explanation})"
      else
        reason = decline_reason_text.presence || decline_reason.name.to_s
        reason += ". Note: #{decline_reason_other_explanation}" if decline_reason_other_explanation.present?
        reason
      end
    end

    private def snapshot_decline_reason_text
      self.decline_reason_text = decline_reason.name if decline_reason_id_changed? && decline_reason.present?
    end
  end
end
