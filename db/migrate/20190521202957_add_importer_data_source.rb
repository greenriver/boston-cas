class AddImporterDataSource < ActiveRecord::Migration[4.2]
  def up
    DataSource.create(name: 'Imported Clients', db_identifier: 'Imported')

    DataSource.find_by(name: 'DND Warehouse')&.update(db_identifier: 'hmis_warehouse')
  end
end
