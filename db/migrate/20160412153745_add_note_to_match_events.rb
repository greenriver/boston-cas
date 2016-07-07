class AddNoteToMatchEvents < ActiveRecord::Migration
  def change
    add_column :match_events, :note, :text
  end
end
