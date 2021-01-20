class AddDeletedAtToUserRole < ActiveRecord::Migration[6.0]
  def change
    add_column :user_roles, :deleted_at, :datetime, index: true
  end
end
