class AddCanSendNotesViaEmailPermission < ActiveRecord::Migration
  def up
    Role.ensure_permissions_exist
  end

  def down
    remove_column :roles, :can_send_notes_via_email, :boolean
  end
end
