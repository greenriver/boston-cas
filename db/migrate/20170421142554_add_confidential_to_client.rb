class AddConfidentialToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :confidential, :boolean, null: false, default: false
    Role.ensure_permissions_exist
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_client_confidentiality: true})
    dnd.update({can_view_client_confidentiality: true})
  end
end
