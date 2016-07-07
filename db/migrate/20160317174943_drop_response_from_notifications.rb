class DropResponseFromNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :response
  end
end
