class AddExcludeFromDirectoryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :exclude_from_directory, :boolean, default: false
  end
end
