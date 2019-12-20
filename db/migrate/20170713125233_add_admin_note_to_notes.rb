class AddAdminNoteToNotes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_events, :admin_note, :boolean, null: false, default: false
  end
end
