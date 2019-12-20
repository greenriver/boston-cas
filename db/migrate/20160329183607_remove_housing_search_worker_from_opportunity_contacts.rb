class RemoveHousingSearchWorkerFromOpportunityContacts < ActiveRecord::Migration[4.2]
  def change
    remove_column :opportunity_contacts, :housing_search_worker, :boolean
  end
end
