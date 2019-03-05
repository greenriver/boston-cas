class CreateEntityViewPermissions < ActiveRecord::Migration
  def change
    create_table :entity_view_permissions do |t|
      t.references :user, index: true
      t.references :entity, null: false, polymorphic: true, index: true
      t.boolean :editable

      t.datetime :deleted_at
    end
  end
end
