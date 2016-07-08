class AddDeletedAtToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :deleted_at,
     :datetime
    add_index :opportunities, :deleted_at, where: "deleted_at IS NULL"
  end
end
