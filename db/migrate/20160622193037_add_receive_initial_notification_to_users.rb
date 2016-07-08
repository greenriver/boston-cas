class AddReceiveInitialNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_initial_notification, :boolean, default: false
  end
end
