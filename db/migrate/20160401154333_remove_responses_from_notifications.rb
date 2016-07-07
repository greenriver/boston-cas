class RemoveResponsesFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :response_action, :string
    remove_column :notifications, :response_at, :datetime
  end
end
