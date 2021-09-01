###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class ReferralEvent < Base
    self.table_name = :cas_referral_events

    CLIENT_ACCEPTED = 1

    def accepted
      update(referral_result: CLIENT_ACCEPTED, referral_result_date: client_opportunity_match.success_time.to_date)
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

    # belongs_to doesn't work because the match and event are in different databases
    def client_opportunity_match
      @client_opportunity_match ||= ClientOpportunityMatch.find(client_opportunity_match_id)
    end

    def self.sync!
      ClientOpportunityMatch.find_each do |match|
        next if !match.active? && !match.closed?

        event = match.init_referral_event
        next unless event.present?

        if match.active?
          next
        elsif match.closed_reason == 'success'
          if event.referral_result != CLIENT_ACCEPTED
            event.update(
              referral_result: CLIENT_ACCEPTED,
              referral_result_date: match.success_time.to_date,
            )
          end
        else
          reason = match.current_decision&.decline_reason
          if reason.present? && reason.referral_result.present?
            if event.referral_result != reason.referral_result
              event.update(
                referral_result: reason.referral_result,
                referral_result_date: reason.referral_result_date,
              )
            end
          else
            event.destroy
          end
        end
      end
    end
  end
end
