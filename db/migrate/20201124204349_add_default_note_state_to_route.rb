class AddDefaultNoteStateToRoute < ActiveRecord::Migration[6.0]
  def change
    add_column :match_routes, :send_notes_by_default, :boolean, null: false, default: false
  end
end
