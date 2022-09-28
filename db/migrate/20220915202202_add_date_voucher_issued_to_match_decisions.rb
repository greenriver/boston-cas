class AddDateVoucherIssuedToMatchDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :date_voucher_issued, :datetime
  end
end
