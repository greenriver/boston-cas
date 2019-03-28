class RouteHasDefaultShelterContacts < ActiveRecord::Migration
  def change
    add_column :match_routes, :default_shelter_agency_contacts_from_project_client, :boolean, default: false, null: false
  end
end
