class AddParanoidToSubgrantees < ActiveRecord::Migration
  def change
    add_column :subgrantees, :deleted_at, :datetime, index: true
  end
end
