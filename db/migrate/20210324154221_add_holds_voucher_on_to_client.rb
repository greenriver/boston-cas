class AddHoldsVoucherOnToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :holds_voucher_on, :date
  end
end
