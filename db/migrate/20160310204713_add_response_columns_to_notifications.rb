class AddResponseColumnsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :response_by, :integer
    add_column :notifications, :response_action, :string
    add_column :notifications, :response_at, :datetime
  end
end
