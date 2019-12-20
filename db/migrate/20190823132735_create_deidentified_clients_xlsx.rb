class CreateDeidentifiedClientsXlsx < ActiveRecord::Migration[4.2]
  def change
    create_table :deidentified_clients_xlsxes do |t|
      t.string :filename
      t.references :user
      t.string :content_type
      t.binary :content

      t.timestamps
    end
  end
end
