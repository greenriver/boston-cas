class DropResponseFromNotifications < ActiveRecord::Migration[4.2]
  def change
    remove_column :notifications, :response
  end
end
