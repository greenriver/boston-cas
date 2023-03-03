###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module AcceptsNotWorkingWithClientReason
    extend ActiveSupport::Concern

    included do
      validate :validate_not_working_with_client_reason
    end

    def step_not_working_with_client_reasons
      [
        'Barred from working with agency',
        'Hospitalized',
        'Don’t know / disappeared',
        'Incarcerated',
      ]
    end

    def not_working_with_client_reasons
      @not_working_with_client_reasons ||= [].tap do |result|
        MatchDecisionReasons::All.where(name: step_not_working_with_client_reasons).find_each do |reason|
          result << reason
        end
      end
    end

    def whitelist_params_for_update params
      result = super
      reason_id_array = Array.wrap params.require(:decision)[:not_working_with_client_reason_id]
      not_working_with_client_reason_id = reason_id_array.select(&:present?).first
      result.merge! not_working_with_client_reason_id: not_working_with_client_reason_id

      result.merge! params.require(:decision).permit(:not_working_with_client_reason_other_explanation)
      return result
    end

    private def validate_not_working_with_client_reason
      return unless not_working_with_client_reason&.other? && not_working_with_client_reason_other_explanation.blank?

      errors.add :not_working_with_client_reason_other_explanation, "must be filled in if choosing 'Other'"
    end

    private def not_working_with_client_reason_status_label
      return nil if not_working_with_client_reason.blank?
      return "Not working with client: Other (#{not_working_with_client_reason_other_explanation})" if not_working_with_client_reason.other?

      "Not working with client: #{not_working_with_client_reason.name}"
    end

    def decline_reason_name
      if not_working_with_client_reason.present?
        return "Other (#{not_working_with_client_reason_other_explanation})" if not_working_with_client_reason.other?

        reason = not_working_with_client_reason.name
        reason += ". Note: #{not_working_with_client_reason_other_explanation}" if not_working_with_client_reason_other_explanation.present?
        reason
      elsif decline_reason.blank?
        'none given'
      elsif decline_reason.other?
        "Other (#{decline_reason_other_explanation})"
      else
        reason = decline_reason.name
        reason += ". Note: #{decline_reason_other_explanation}" if decline_reason_other_explanation.present?
        reason
      end
    end
  end
end
