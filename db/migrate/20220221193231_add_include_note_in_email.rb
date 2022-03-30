class AddIncludeNoteInEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :include_note_in_email, :boolean, default: nil
    add_column :configs, :include_note_in_email_default, :boolean, default: nil
  end
end
