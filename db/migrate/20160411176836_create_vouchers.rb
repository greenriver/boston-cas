class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.boolean :available
      t.date :date_available
      t.references :sub_program, index: true, foreign_key: true
      t.references :unit, index: true, foreign_key: true

      t.timestamps null: false
      t.datetime :deleted_at, index: true, null: true
    end
  end
end
