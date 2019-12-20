class SetOpportunityAvailableNotNullDefaultFalse < ActiveRecord::Migration[4.2]
  def change
    change_column :opportunities, :available, :boolean, null: false, default: false
  end
end
