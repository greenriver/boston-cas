class RenameOptOutFlag < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :opt_out_match_digest_email, :boolean, default: false
    add_column :users, :receive_weekly_match_summary_email, :boolean, default: true
  end
end
