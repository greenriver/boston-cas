class AddLastChangedToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :source_last_changed, :datetime
  end
end
