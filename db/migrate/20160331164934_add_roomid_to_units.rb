class AddRoomidToUnits < ActiveRecord::Migration[4.2]
  def change
     create_table :units do |t|
      t.integer :roomid
      t.string :name
      t.boolean :available
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :geo_code
      t.string :target_population_a
      t.string :target_population_b
      t.boolean :mc_kinney_vento

      # See 2.7B in https://www.hudexchange.info/resources/documents/Notice-CPD-15-010-2016-HIC-PIT-Data-Collection-Notice.pdf
      t.integer :chronic
      t.integer :veteran
      t.integer :adult_only
      t.integer :family
      t.integer :child_only
      t.references :building, index: true, null: false
      t.timestamps null: false
      t.datetime :deleted_at
    end
    
    add_index :units, :deleted_at, where: "deleted_at IS NULL"
    add_index :units, :roomid
  end
end
