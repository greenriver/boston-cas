class AddVaAndHuesEligibility < ActiveRecord::Migration
  def change
    add_column :project_clients, :va_eligible, :boolean, null: false, default: false
    add_column :clients, :va_eligible, :boolean, null: false, default: false
    add_column :project_clients, :hues_eligible, :boolean, null: false, default: false
    add_column :clients, :hues_eligible, :boolean, null: false, default: false
    add_column :roles, :can_view_va_eligibility, :boolean, null: false, default: false
    add_column :roles, :can_view_hues_eligibility, :boolean, null: false, default: false
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update({can_view_va_eligibility: true, can_view_hues_eligibility: true})
    dnd.update({can_view_va_eligibility: true, can_view_hues_eligibility: true})
  end
end
