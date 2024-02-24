class RemoveExtraneousReferralEvents < ActiveRecord::Migration[6.1]
  def up
    # This is only relevant for historic data,
    # don't do anything if it's after 4/1/2024
    return if Date.current > '2024-04-01'.to_date

    keep_ids = {}
    Warehouse::ReferralEvent.find_each do |event|
      # given the following fields, pick a unique event to keep
      key = [
        event.cas_client_id,
        event.hmis_client_id,
        event.program_id,
        event.client_opportunity_match_id,
        event.referral_date,
        event.referral_result,
        event.referral_result_date,
        event.event,
      ]
      keep_ids[key] ||= event.id
    end
    Warehouse::ReferralEvent.where.not(id: keep_ids.values).delete_all
  end
end
