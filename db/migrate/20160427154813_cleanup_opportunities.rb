class CleanupOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :success, :boolean, default: false
    remove_column :opportunities, :building_id
    remove_column :opportunities, :address
    remove_column :opportunities, :city
    remove_column :opportunities, :state
    remove_column :opportunities, :zip_code
    remove_column :opportunities, :geo_code
    remove_column :opportunities, :target_population_a
    remove_column :opportunities, :target_population_b
    remove_column :opportunities, :mc_kinney_vento
    remove_column :opportunities, :chronic
    remove_column :opportunities, :veteran
    remove_column :opportunities, :adult_only
    remove_column :opportunities, :family
    remove_column :opportunities, :child_only
  end
end
