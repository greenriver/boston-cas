class RemoveHousingSearchWorkerFromOpportunityContacts < ActiveRecord::Migration
  def change
    remove_column :opportunity_contacts, :housing_search_worker, :boolean
  end
end
