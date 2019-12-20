class RemovePasswordDigestFromUsers < ActiveRecord::Migration[4.2]
  def change
    change_table(:users) do |t|
      remove_column :users, :password_digest # removing password_digest since Devise doesn't use it
    end
  end
end
