class AddDatesToDecision < ActiveRecord::Migration
  def change
    add_column :match_decisions, :client_last_seen_date, :datetime
    add_column :match_decisions, :criminal_hearing_date, :datetime
    add_column :match_decisions, :client_move_in_date, :datetime
  end
end
