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
    end

    def decline_reasons(contact:)
      @decline_reasons ||= [].tap do |result|
        MatchDecisionReasons::Base.active.where(name: step_decline_reasons(contact)).find_each do |reason|
          result << reason
        end
        # Move other to the end of the list
        result.sort_by! { |m| [m.name.downcase == 'other' ? 1 : 0, m.name.downcase] }
        result.map! do |reason|
          # Only include the asterisks if more than 'Other' requires additional explanation && if not ALL decline reasons require additional explanation
          not_other = decline_reasons_not_other_requiring_explanation(contact)
          more_than_other_requires_explanation = not_other.present?
          this_reason_requires_explanation = not_other.include?(reason.name)

          include_asterisk = if all_declines_require_explanation(contact)
            false
          elsif more_than_other_requires_explanation && (reason.other? || this_reason_requires_explanation)
            true
          end

          name = reason.name
          name += '*' if include_asterisk
          [name, reason.id]
        end
      end
    end

    def all_declines_require_explanation(contact)
      not_other = decline_reasons_not_other_requiring_explanation(contact)
      step_reasons_except_other = step_decline_reasons(contact).reject { |r| r == 'Other' }
      not_other.sort == step_reasons_except_other.sort
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
        reason = decline_reason.name.to_s
        reason += ". Note: #{decline_reason_other_explanation}" if decline_reason_other_explanation.present?
        reason
      end
    end
  end
end
