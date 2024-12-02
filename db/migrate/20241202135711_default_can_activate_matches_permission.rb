class DefaultCanActivateMatchesPermission < ActiveRecord::Migration[7.0]
  def up
    # Preserve existing behavior by default
    Role.where(can_edit_all_clients: true).update_all(can_activate_matches: true)
  end
end
