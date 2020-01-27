class AddCanViewAllAlternates < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_see_all_alternate_matches, :boolean
  end
end
