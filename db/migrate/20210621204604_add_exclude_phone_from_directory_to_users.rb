class AddExcludePhoneFromDirectoryToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :exclude_phone_from_directory, :boolean, default: false
  end
end
