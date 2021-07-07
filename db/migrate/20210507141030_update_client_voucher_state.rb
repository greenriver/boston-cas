class UpdateClientVoucherState < ActiveRecord::Migration[6.0]
  def up
    Client.active_in_match.where(holds_voucher_on: nil).find_each do |client|
      match = client.client_opportunity_matches.active.detect { |m| m.current_decision&.holds_voucher? }
      next unless match.present?

      client.update(holds_voucher_on: match.current_decision.timestamp.to_date)
    end
  end
end
