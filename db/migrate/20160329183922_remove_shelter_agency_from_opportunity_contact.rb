class RemoveShelterAgencyFromOpportunityContact < ActiveRecord::Migration[4.2]
  def change
    remove_column :opportunity_contacts, :shelter_agency, :boolean
  end
end
