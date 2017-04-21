class AddConfidentialToClient < ActiveRecord::Migration
  def change
    add_column :clients, :confidential, :boolean, null: false, default: false
    add_column :roles, :can_view_client_confidentiality, :boolean, null: false, default: false
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_client_confidentiality: true})
    dnd.update({can_view_client_confidentiality: true})
  end
end
