class AddExpiresAtToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :expires_at, :datetime
  end
end
