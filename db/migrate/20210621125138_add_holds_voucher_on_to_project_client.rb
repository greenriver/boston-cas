class AddHoldsVoucherOnToProjectClient < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :holds_voucher_on, :date
    add_column :clients, :holds_internal_cas_voucher, :boolean
  end
end
