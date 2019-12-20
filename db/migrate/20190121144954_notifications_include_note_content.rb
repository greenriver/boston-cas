class NotificationsIncludeNoteContent < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :include_content, :boolean, default: true
  end
end
