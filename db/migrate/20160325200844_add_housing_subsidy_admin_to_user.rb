class AddHousingSubsidyAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :housing_subsidy_admin, :boolean
    add_index :users, :housing_subsidy_admin
  end
end
