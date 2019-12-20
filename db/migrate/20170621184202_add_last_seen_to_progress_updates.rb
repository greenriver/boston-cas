class AddLastSeenToProgressUpdates < ActiveRecord::Migration[4.2]
  def change
    add_column :match_progress_updates, :client_last_seen, :date
  end
end
