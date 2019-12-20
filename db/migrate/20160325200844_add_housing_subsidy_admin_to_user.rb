class AddHousingSubsidyAdminToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :housing_subsidy_admin, :boolean
    add_index :users, :housing_subsidy_admin
  end
end
