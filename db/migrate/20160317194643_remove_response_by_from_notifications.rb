class RemoveResponseByFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :response_by
  end
end
