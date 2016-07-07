class AddExpiresAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :expires_at, :datetime
  end
end
