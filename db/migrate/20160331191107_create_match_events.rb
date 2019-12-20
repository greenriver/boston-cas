class CreateMatchEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :match_events do |t|
      t.string :type
      t.references :match, index: true
      t.references :notification, index: true
      t.references :decision, index: true
      t.references :contact
      t.string :action
      t.timestamps null: false
    end
  end
end
