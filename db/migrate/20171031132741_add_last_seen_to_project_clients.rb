class AddLastSeenToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :last_seen, :date

    add_column :clients, :last_seen, :date
  end
end
