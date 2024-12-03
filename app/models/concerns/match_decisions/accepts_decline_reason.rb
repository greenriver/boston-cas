###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module AcceptsDeclineReason
    extend ActiveSupport::Concern

    included do
      validate :validate_decline_reason
    end

    def decline_reasons(contact:)
      @_decline_reasons ||= [].tap do |result| # rubocop:disable Naming/MemoizedInstanceVariableName
        MatchDecisionReasons::Base.active.where(name: step_decline_reasons(contact)).find_each do |reason|
          result << reason
        end
        # Move other to the end of the list
        result.sort_by! { |m| [m.name.downcase == 'other' ? 1 : 0, m.name.downcase] }
        result.map! do |reason|
          # Only include the asterisks if more than 'Other' requires additional explanation
          include_asterisk = decline_reasons_not_other_requiring_explanation.present? && (reason.other? || decline_reasons_not_other_requiring_explanation.include?(reason.name))
          name = reason.name
          name += '*' if include_asterisk
          [name, reason.id]
        end
      end
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
      errors.add :decline_reason, 'please indicate the reason for declining' if status == 'declined' && decline_reason_blank?

      explanation_field_required = status == 'declined' && (decline_reason.other? || decline_reasons_not_other_requiring_explanation&.include?(decline_reason.name))
      errors.add :decline_reason_other_explanation, "must be filled in if choosing '#{decline_reason.name}'" if explanation_field_required && decline_reason_other_explanation.blank?
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
