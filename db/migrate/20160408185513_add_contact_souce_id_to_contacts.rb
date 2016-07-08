class AddContactSouceIdToContacts < ActiveRecord::Migration
  def change
    add_column :data_sources, :db_itentifier, :string

    add_column :contacts, :id_in_data_source, :integer
    add_column :contacts, :data_source_id, :integer
    add_column :contacts, :data_source_id_column_name, :string

    rename_column :buildings, :data_source_id, :id_in_data_source
    add_column :buildings, :data_source_id, :integer
    add_column :buildings, :data_source_id_column_name, :string

    add_column :funding_sources, :id_in_data_source, :integer
    add_column :funding_sources, :data_source_id, :integer
    add_column :funding_sources, :data_source_id_column_name, :string

    remove_column :project_clients, :data_source_id, :string
    rename_column :project_clients, :clid, :id_in_data_source
    add_column :project_clients, :data_source_id, :integer
    add_column :project_clients, :data_source_id_column_name, :string

    rename_column :project_programs, :entity_id, :id_in_data_source
    add_column :project_programs, :data_source_id, :integer
    add_column :project_programs, :data_source_id_column_name, :string

    rename_column :subgrantees, :site_id, :id_in_data_source
    add_column :subgrantees, :data_source_id, :integer
    add_column :subgrantees, :data_source_id_column_name, :string

    rename_column :units, :roomid, :id_in_data_source
    add_column :units, :data_source_id, :integer
    add_column :units, :data_source_id_column_name, :string

  end
end
