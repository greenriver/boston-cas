class RemoveShelterAgencyFromOpportunityContact < ActiveRecord::Migration
  def change
    remove_column :opportunity_contacts, :shelter_agency, :boolean
  end
end
