###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class ReferralEvent < Base
    self.table_name = :cas_referral_events

    belongs_to :client, foreign_key: :cas_client_id, inverse_of: :referral_events
    belongs_to :client_opportunity_match, inverse_of: :referral_event

    def accepted
      update(referral_result: 1, referral_result_date: client_opportunity_match.success_time.to_date)
    end

    def rejected
      reason = client_opportunity_match.current_decision&.decline_reason
      if reason&.referral_result.present?
        update(referral_result: reason.referral_result, referral_result_date: reason.referral_result_date)
      else
        destroy
      end
    end

    def clear
      update(referral_result: nil, referral_result_date: nil)
    end
  end
end