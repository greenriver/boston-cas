class RouteHasDefaultShelterContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :default_shelter_agency_contacts_from_project_client, :boolean, default: false, null: false
  end
end
