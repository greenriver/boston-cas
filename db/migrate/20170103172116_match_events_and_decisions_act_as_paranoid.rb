class MatchEventsAndDecisionsActAsParanoid < ActiveRecord::Migration[4.2]
  def change
    add_column :match_events, :deleted_at, :datetime
    add_column :match_decisions, :deleted_at, :datetime
  end
end
