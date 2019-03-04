class CreateEntityViewPermissions < ActiveRecord::Migration
  def change
    create_table :entity_view_permissions do |t|
      t.references :user
      t.references :entity, null: false, polymorphic: true
      t.datetime :deleted_at
    end
  end
end
