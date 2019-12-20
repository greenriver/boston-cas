class RemoveResponseByFromNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :notifications, :response_by
  end
end
