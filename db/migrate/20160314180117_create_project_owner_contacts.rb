class CreateProjectOwnerContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :project_owner_contacts do |t|
      t.references :project_owner, index: true, null: false
      t.references :contact, index: true, null: false
      t.timestamps null: false
      t.datetime :deleted_at, index: true
      
    end
  end
end
