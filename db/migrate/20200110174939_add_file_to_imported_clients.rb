class AddFileToImportedClients < ActiveRecord::Migration[6.0]
  def change
    add_column :imported_clients_csvs, :file, :text
    add_column :deidentified_clients_xlsxes, :file, :text
  end
end
