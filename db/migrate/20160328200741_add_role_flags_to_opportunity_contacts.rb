class AddRoleFlagsToOpportunityContacts < ActiveRecord::Migration
  def change
    add_column :opportunity_contacts, :housing_subsidy_admin, :boolean, null: false, default: false
    add_column :opportunity_contacts, :shelter_agency, :boolean, null: false, default: false
    add_column :opportunity_contacts, :housing_search_worker, :boolean, null: false, default: false
  end
end
