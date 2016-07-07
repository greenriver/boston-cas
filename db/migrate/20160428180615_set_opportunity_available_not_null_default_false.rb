class SetOpportunityAvailableNotNullDefaultFalse < ActiveRecord::Migration
  def change
    change_column :opportunities, :available, :boolean, null: false, default: false
  end
end
