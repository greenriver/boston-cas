class CreateProgramContacts < ActiveRecord::Migration
  def change
    create_table :program_contacts do |t|
      t.references :program, null: false, index: true
      t.references :contact, null: false, index: true
      t.timestamps null: false
      t.datetime :deleted_at
      t.boolean :dnd_staff, default: false, null: false
      t.boolean :housing_subsidy_admin, default: false, null: false
      t.boolean :client, default: false, null: false
      t.boolean :housing_search_worker, default: false, null: false
      t.boolean :shelter_agency, default: false, null: false
      t.boolean :ssp, default: false, null: false
      t.boolean :hsp, default: false, null: false
    end
  end
end
