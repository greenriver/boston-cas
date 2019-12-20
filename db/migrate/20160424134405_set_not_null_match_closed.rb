class SetNotNullMatchClosed < ActiveRecord::Migration[4.2]
  def change
    change_column :client_opportunity_matches, :closed, :boolean, default: false, null: false
  end
end
