class RemoveColumnsFromMatchStatusUpdate < ActiveRecord::Migration[4.2]
  def change
    remove_column :match_progress_updates, :due_at, :datetime
    remove_column :match_progress_updates, :notify_dnd_at, :datetime
  end
end
