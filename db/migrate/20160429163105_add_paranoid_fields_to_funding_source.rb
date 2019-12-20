class AddParanoidFieldsToFundingSource < ActiveRecord::Migration[4.2]
  def change
    add_column :funding_sources, :deleted_at, :datetime, index: true
  end
end
