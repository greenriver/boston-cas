class AddVoucherRulePermission < ActiveRecord::Migration[6.0]
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_edit_voucher_rules, :boolean
  end
end
