class AddViewOnClosedMatchesPermission < ActiveRecord::Migration
  def change
    Role.ensure_permissions_exist
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_own_closed_matches: true})
    dnd.update({can_view_own_closed_matches: true})
  end
end
