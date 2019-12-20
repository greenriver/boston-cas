class AddHivPositive < ActiveRecord::Migration[4.2]
  def up
    add_column :project_clients, :hiv_positive, :boolean, default: false, null: false
    add_column :project_clients, :housing_release_status, :string
    add_column :clients, :hiv_positive, :boolean, default: false, null: false
    add_column :clients, :housing_release_status, :string
    Role.ensure_permissions_exist
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_hiv_positive_eligibility: true})
    dnd.update({can_view_hiv_positive_eligibility: true})
  end

  def down
    remove_column :project_clients, :hiv_positive, :boolean, default: false, null: false
    remove_column :project_clients, :housing_release_type, :string
    remove_column :clients, :hiv_positive, :boolean, default: false, null: false
    remove_column :clients, :housing_release_status, :string
    Role.ensure_permissions_exist
  end

end
