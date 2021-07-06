class SetInternalVoucher < ActiveRecord::Migration[6.0]
  def up
    Client.where.not(holds_voucher_on: nil).update_all(holds_internal_cas_voucher: true)
  end
end
