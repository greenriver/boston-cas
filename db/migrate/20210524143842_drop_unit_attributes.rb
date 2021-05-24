class DropUnitAttributes < ActiveRecord::Migration[6.0]
  def up
    drop_table :unit_attributes, if_exists: true
  end

  def down
    create_table "unit_attributes", force: :cascade do |t|
      t.bigint "unit_id"
      t.string "name"
      t.string "value"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.datetime "deleted_at"
      t.index ["unit_id"], name: "index_unit_attributes_on_unit_id"
    end
  end
end
