class AddNoteToMatchEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :match_events, :note, :text
  end
end
