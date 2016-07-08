class SetNotNullMatchClosed < ActiveRecord::Migration
  def change
    change_column :client_opportunity_matches, :closed, :boolean, default: false, null: false
  end
end
