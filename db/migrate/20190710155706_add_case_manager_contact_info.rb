class AddCaseManagerContactInfo < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :case_manager_contact_info, :string
    add_column :clients, :case_manager_contact_info, :string
  end
end
