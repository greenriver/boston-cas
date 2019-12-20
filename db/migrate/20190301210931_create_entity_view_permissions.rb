class CreateEntityViewPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :entity_view_permissions do |t|
      t.references :user, index: true
      t.references :entity, null: false, polymorphic: true, index: true
      t.boolean :editable

      t.datetime :deleted_at
    end
  end
end
