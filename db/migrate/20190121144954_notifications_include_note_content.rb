class NotificationsIncludeNoteContent < ActiveRecord::Migration
  def change
    add_column :notifications, :include_content, :boolean, default: true
  end
end
