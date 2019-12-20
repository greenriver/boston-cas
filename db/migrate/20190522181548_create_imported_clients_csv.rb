class CreateImportedClientsCsv < ActiveRecord::Migration[4.2]
  def change
    create_table :imported_clients_csvs do |t|
      t.string :filename
      t.references :user
      t.string :content_type
      t.string :content

      t.timestamps
    end
  end
end
