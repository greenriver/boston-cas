class RemoveResponsesFromNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :notifications, :response_action, :string
    remove_column :notifications, :response_at, :datetime
  end
end
