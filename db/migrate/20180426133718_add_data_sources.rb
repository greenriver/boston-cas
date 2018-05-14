class AddDataSources < ActiveRecord::Migration
  def up
    rename_column :data_sources, :db_itentifier, :db_identifier
    DataSource.create(name: 'Deidentified Clients', db_identifier: 'Deidentified')
  end
end
