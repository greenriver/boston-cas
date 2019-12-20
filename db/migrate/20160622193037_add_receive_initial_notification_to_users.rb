class AddReceiveInitialNotificationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :receive_initial_notification, :boolean, default: false
  end
end
