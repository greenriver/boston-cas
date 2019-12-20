class CreateMatchProgressUpdates < ActiveRecord::Migration[4.2]
  def change
    create_table :match_progress_updates do |t|
      t.string :type, index: true, null: false
      t.references :match, index: true, null: false
      t.references :notification, index: true, null: true
      t.references :contact, index: true, null: false
      t.references :decision, index: true, null: true
      t.integer :notification_number

      t.datetime :requested_at
      t.datetime :due_at
      t.datetime :submitted_at
      t.datetime :notify_dnd_at
      t.datetime :dnd_notified_at

      t.string :response
      t.text :note

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
