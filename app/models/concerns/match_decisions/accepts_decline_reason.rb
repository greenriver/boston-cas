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

    # FIXME: remove 'include_other' after migration
    def decline_reasons(include_other: true, contact:)
      @_decline_reasons ||= [].tap do |result| # rubocop:disable Naming/MemoizedInstanceVariableName
        # FIXME: remove if/else after migration
        if respond_to?(:step_decline_reasons)
          MatchDecisionReasons::All.where(name: step_decline_reasons(contact)).find_each do |reason|
            result << reason
          end
        else
          decline_reason_scope(contact).each do |reason|
            result << reason
          end
          result << MatchDecisionReasons::Other.first if include_other
        end
      end
    end

    private def decline_reason_scope(_contact)
      # just the base scope.  other gets included automatically by #decline_reasons
      raise 'abstract method not implemented'
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

      errors.add :decline_reason_other_explanation, "must be filled in if choosing 'Other'" if status == 'declined' && decline_reason&.other? && decline_reason_other_explanation.blank?
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
