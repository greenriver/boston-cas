class CreateNotificationsContact < ActiveRecord::Migration
  def change
    remove_column :notifications, :recipient
    add_column :notifications, :recipient_id, :integer
  end
end
