class CreateNotificationsContact < ActiveRecord::Migration[4.2]
  def change
    remove_column :notifications, :recipient
    add_column :notifications, :recipient_id, :integer
  end
end
