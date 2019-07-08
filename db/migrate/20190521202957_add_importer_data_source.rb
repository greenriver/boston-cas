class AddImporterDataSource < ActiveRecord::Migration
  def up
    DataSource.create(name: 'Imported Clients', db_identifier: 'Imported')

    DataSource.find_by(name: 'DND Warehouse')&.update(db_identifier: 'hmis_warehouse')
  end
end
