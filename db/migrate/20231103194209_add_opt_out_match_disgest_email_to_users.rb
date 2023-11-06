class AddOptOutMatchDisgestEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :opt_out_match_digest_email, :boolean, default: false
  end
end
