class AddTagsPermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_manage_tags, :boolean, default: false
  end
end
