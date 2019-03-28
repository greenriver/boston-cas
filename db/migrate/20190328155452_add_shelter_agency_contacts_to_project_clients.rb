class AddShelterAgencyContactsToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :default_shelter_agency_contacts, :jsonb
  end
end
