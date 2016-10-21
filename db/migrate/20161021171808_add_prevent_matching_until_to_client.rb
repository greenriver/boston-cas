class AddPreventMatchingUntilToClient < ActiveRecord::Migration
  def change
    add_column :clients, :prevent_matching_until, :date
  end
end
