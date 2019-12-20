class AddLastChangedToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :source_last_changed, :datetime
  end
end
