class AddPreventMatchingUntilToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :prevent_matching_until, :date
  end
end
