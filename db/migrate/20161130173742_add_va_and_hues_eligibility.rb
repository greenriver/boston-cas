class AddVaAndHuesEligibility < ActiveRecord::Migration[4.2]
  def up
    add_column :project_clients, :va_eligible, :boolean, null: false, default: false
    add_column :clients, :va_eligible, :boolean, null: false, default: false
    add_column :project_clients, :hues_eligible, :boolean, null: false, default: false
    add_column :clients, :hues_eligible, :boolean, null: false, default: false
    unless column_exists? :roles, :can_view_va_eligibility
        add_column :roles, :can_view_va_eligibility, :boolean, null: false, default: false
        add_column :roles, :can_view_hues_eligibility, :boolean, null: false, default: false
    end
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_va_eligibility: true, can_view_hues_eligibility: true})
    dnd.update({can_view_va_eligibility: true, can_view_hues_eligibility: true})
  end

  def down
    remove_column :project_clients, :va_eligible, :boolean, null: false, default: false
    remove_column :clients, :va_eligible, :boolean, null: false, default: false
    remove_column :project_clients, :hues_eligible, :boolean, null: false, default: false
    remove_column :clients, :hues_eligible, :boolean, null: false, default: false
    remove_column :roles, :can_view_va_eligibility, :boolean, null: false, default: false
    remove_column :roles, :can_view_hues_eligibility, :boolean, null: false, default: false
  end
end
