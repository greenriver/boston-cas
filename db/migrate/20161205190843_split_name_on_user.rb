class SplitNameOnUser < ActiveRecord::Migration
  def up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    User.all.each do |u|
      first_name, last_name = u[:name].split(' ', 2)
      u.update(first_name: first_name, last_name: last_name)
    end
    remove_column :users, :name
  end

  def down
    add_column :users, :name, :string
    User.all.each do |u|
      u.update(name: "#{u.first_name} #{u.last_name}")
    end
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
