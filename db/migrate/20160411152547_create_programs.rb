class CreatePrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :programs do |t|
      t.string :name
      t.string :contract_start_date
      t.references :funding_source, index: true, foreign_key: true
      t.references :subgrantee, index: true, foreign_key: true
      
      t.references :contact, index: true, foreign_key: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true, null: true
    end
  end
end
