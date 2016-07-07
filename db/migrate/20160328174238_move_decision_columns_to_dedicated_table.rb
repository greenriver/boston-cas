class MoveDecisionColumnsToDedicatedTable < ActiveRecord::Migration
  def change
    remove_column :client_opportunity_matches, :match_recommendation_dnd_staff_status
    remove_column :client_opportunity_matches, :match_recommendation_dnd_staff_contact_id
    remove_column :client_opportunity_matches, :match_recommendation_dnd_staff_timestamp
    remove_column :client_opportunity_matches, :match_recommendation_client_status
    remove_column :client_opportunity_matches, :match_recommendation_client_contact_id
    remove_column :client_opportunity_matches, :match_recommendation_client_timestamp
    remove_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_status
    remove_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_contact_id
    remove_column :client_opportunity_matches, :match_recommendation_housing_subsidy_admin_timestamp
    
    create_table :match_decisions do |t|
      t.references :match, index: true
      t.string :type
      t.string :status
      t.references :contact
      t.timestamps
    end
    
  end
end
