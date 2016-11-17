class AddDmhEligiblePermission < ActiveRecord::Migration
  def change
    add_column :roles, :can_view_dmh_eligibility, :boolean, null: false, default: false
    admin = Role.where(name: 'admin').first
    dnd = Role.where(name: 'dnd_staff').first
    admin.update(can_view_dmh_eligibility: true)
    dnd.update(can_view_dmh_eligibility: true)
  end
end
