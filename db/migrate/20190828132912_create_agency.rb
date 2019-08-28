class CreateAgency < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name

      t.timestamps
    end

    add_reference :users, :agency
    rename_column :users, :agency, :deprecated_agency
  end
end
