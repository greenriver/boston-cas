class AddClientNotesTable < ActiveRecord::Migration
  def change
    create_table :client_notes do |t|
      t.references :user, null: false
      t.references :client, null: false
      t.string :note
  
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
