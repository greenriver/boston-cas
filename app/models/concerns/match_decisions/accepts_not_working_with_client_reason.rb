###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  module AcceptsNotWorkingWithClientReason
    extend ActiveSupport::Concern

    included do
      validate :validate_not_working_with_client_reason
    end

    def not_working_with_client_reasons
      @_not_working_with_client_reasons ||= [].tap do |result|
        MatchDecisionReasons::ShelterAgencyNotWorkingWithClient.all.each do |reason|
          result << reason
        end
        result << MatchDecisionReasons::ShelterAgencyNotWorkingWithClientOther.first
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
      if not_working_with_client_reason&.other? && not_working_with_client_reason_other_explanation.blank?
        errors.add :not_working_with_client_reason_other_explanation, "must be filled in if choosing 'Other'"
      end
    end

    private def not_working_with_client_reason_status_label
      if not_working_with_client_reason.blank?
        return nil
      elsif not_working_with_client_reason.other?
        "Not working with client: Other (#{not_working_with_client_reason_other_explanation})"
      else
        "Not working with client: #{not_working_with_client_reason.name}"
      end
    end

    def decline_reason_name
      if not_working_with_client_reason.present?
        if not_working_with_client_reason.other?
          "Other (#{not_working_with_client_reason_other_explanation})"
        else
          reason = not_working_with_client_reason.name
          if not_working_with_client_reason_other_explanation.present?
            reason += ". Note: #{not_working_with_client_reason_other_explanation}"
          end
          reason
        end
      elsif decline_reason.blank?
        "none given"
      elsif decline_reason.other?
        "Other (#{decline_reason_other_explanation})"
      else
        reason = decline_reason.name
        if decline_reason_other_explanation.present?
          reason += ". Note: #{decline_reason_other_explanation}"
        end
        reason
      end
    end
  end
end