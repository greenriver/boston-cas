class CreateSubPrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :sub_programs do |t|
      t.string :program_type
      t.references :program, index: true, foreign_key: true

      t.references :building, index: true, foreign_key: true
      t.references :contact, index: true, foreign_key: true
      t.references :subgrantee, index: true, foreign_key: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true, null: true
    end
  end
end
