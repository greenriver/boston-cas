class AddSendNotificationsToMatchRoutes < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :send_notifications, :boolean, default: true
  end
end
