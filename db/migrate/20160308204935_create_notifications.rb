class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.string :type
      t.string :code

      t.timestamps null: false
    end
  end
end
