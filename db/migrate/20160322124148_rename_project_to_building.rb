class RenameProjectToBuilding < ActiveRecord::Migration[4.2]
  def change
    rename_table :projects, :buildings
    rename_table :project_contacts, :building_contacts

    rename_column :buildings, :project_type, :building_type
    rename_column :building_contacts, :project_id, :building_id
    rename_column :opportunities, :project_id, :building_id
  end
end
