class AddAgencyToEntityViewPermissions < ActiveRecord::Migration[6.0]
  def change
    add_reference :entity_view_permissions, :agency, index: true
  end
end
