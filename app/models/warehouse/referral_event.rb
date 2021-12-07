###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class ReferralEvent < Base
    self.table_name = :cas_referral_events
    include ArelHelper

    CLIENT_ACCEPTED = 1

    scope :external_referrals, -> do
      where(client_opportunity_match_id: nil)
    end

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
      sync_match_referrals!
      sync_external_referrals!
    end

    def self.sync_match_referrals!
      ClientOpportunityMatch.preload(:sub_program).find_each do |match|
        # Match is in a weird state, abort
        next if ! match.active? && ! match.closed?

        event = match.init_referral_event
        next unless event.present?

        # Match hasn't finished
        next if match.active?

        if match.closed_reason == 'success'
          if event.referral_result != CLIENT_ACCEPTED
            event.update(
              event: match.sub_program.event,
              referral_result: CLIENT_ACCEPTED,
              referral_result_date: match.success_time.to_date,
            )
          end
        else
          reason = match.current_decision&.decline_reason
          if reason.present? && reason.referral_result.present?
            if event.referral_result != reason.referral_result
              event.update(
                event: match.sub_program.event,
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

    # NOTE: this currently assumes Warehouse::ReferralEvents with no client_opportunity_match_id are external referrals
    def self.sync_external_referrals!
      transaction do
        external_referrals.delete_all
        hmis_client_id_lookup = ProjectClient.from_hmis.pluck(:client_id, :id_in_data_source).to_h

        hmis_client_id_lookup.merge!(
          NonHmisClient.joins(:project_client).
            where.not(warehouse_client_id: nil).
            pluck(pc_t[:client_id], :warehouse_client_id).
            to_h,
        )
        batch = []
        ExternalReferral.preload(:client).find_each do |er|
          hmis_client_id = hmis_client_id_lookup[er.client_id]
          # Skip anyone who's CAS only since we won't be able to connect the event to an enrollment later
          next unless hmis_client_id

          batch << {
            cas_client_id: er.client_id,
            hmis_client_id: hmis_client_id,
            referral_date: er.referred_on,
            event: 17, # NOTE: for now, these are all referral to EHV
          }
        end
        import(batch)
      end
    end
  end
end
