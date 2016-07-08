class CreateClientOpportunityMatchContacts < ActiveRecord::Migration
  def change
    create_table :client_opportunity_match_contacts do |t|
      t.references :match, index: true, null: false
      t.references :contact, index: true, null: false
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      t.boolean :dnd_staff, null: false, default: false
      t.boolean :housing_subsidy_admin, null: false, default: false
      t.boolean :client, null: false, default: false
      t.boolean :housing_search_worker, null: false, default: false
      t.boolean :shelter_agency, null: false, default: false
      
    end
  end
end
