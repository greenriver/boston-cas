class AddMatchSummaryEmailDayToConfig < ActiveRecord::Migration[6.1]
  def change
    add_column :configs, :send_match_summary_email_on, :integer
  end
end
