class AddClientOpportunityMatchColumnsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :client_opportunity_match_id, :int
    add_column :notifications, :response, :string
    add_column :notifications, :recipient, :string
  end
end