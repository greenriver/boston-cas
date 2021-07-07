class UpdateClientVoucherState < ActiveRecord::Migration[6.0]
  def up
    Client.add_missing_holds_voucher_on
  end
end
