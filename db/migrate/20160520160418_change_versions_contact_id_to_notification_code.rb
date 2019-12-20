class ChangeVersionsContactIdToNotificationCode < ActiveRecord::Migration[4.2]
  def change
    remove_column :versions, :contact_id
    add_column :versions, :notification_code, :string
  end
end
