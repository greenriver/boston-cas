class AddDeveloperRole < ActiveRecord::Migration
  def up 
    unless ActiveRecord::Base.connection.column_exists?(:roles, :can_become_other_users)
      add_column :roles, :can_become_other_users, :boolean, default: false
      developer = Role.where(name: 'developer').first_or_create
      Role.update_all(can_become_other_users: false)
      developer.update(can_become_other_users: true)
    end
  end

  def down
    remove_column :roles, :can_become_other_users
  end
end
