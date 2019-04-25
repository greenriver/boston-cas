class AddSendNotificationsToMatchRoutes < ActiveRecord::Migration
  def change
    add_column :match_routes, :send_notifications, :boolean, default: true
  end
end
