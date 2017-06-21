class AddLastSeenToProgressUpdates < ActiveRecord::Migration
  def change
    add_column :match_progress_updates, :client_last_seen, :date
  end
end
