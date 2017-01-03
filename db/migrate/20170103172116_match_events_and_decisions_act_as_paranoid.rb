class MatchEventsAndDecisionsActAsParanoid < ActiveRecord::Migration
  def change
    add_column :match_events, :deleted_at, :datetime
    add_column :match_decisions, :deleted_at, :datetime
  end
end
