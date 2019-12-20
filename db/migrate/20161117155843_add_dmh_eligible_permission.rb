class AddDmhEligiblePermission < ActiveRecord::Migration[4.2]
  def up
    unless column_exists?(:roles, :can_view_dmh_eligibility)
      add_column :roles, :can_view_dmh_eligibility, :boolean, null: false, default: false
      admin = Role.where(name: 'admin').first
      dnd = Role.where(name: 'dnd_staff').first
      admin.update(can_view_dmh_eligibility: true)
      dnd.update(can_view_dmh_eligibility: true)
    end
  end

  def down
    remove_column :roles, :can_view_dmh_eligibility, :boolean, null: false, default: false
  end
end
