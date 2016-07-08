class AddParanoidFieldsToFundingSource < ActiveRecord::Migration
  def change
    add_column :funding_sources, :deleted_at, :datetime, index: true
  end
end
