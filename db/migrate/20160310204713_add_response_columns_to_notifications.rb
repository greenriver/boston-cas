class AddResponseColumnsToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :response_by, :integer
    add_column :notifications, :response_action, :string
    add_column :notifications, :response_at, :datetime
  end
end
