class CreateAdminConfig < ActiveRecord::Migration
  def change
    create_table :configs do |t|
      t.integer :stalled_interval, null: false
      t.integer :dnd_interval, null: false
      t.string :warehouse_url, null: false
    end
  end
end
