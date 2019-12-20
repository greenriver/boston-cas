class AddParanoidToSubgrantees < ActiveRecord::Migration[4.2]
  def change
    add_column :subgrantees, :deleted_at, :datetime, index: true
  end
end
