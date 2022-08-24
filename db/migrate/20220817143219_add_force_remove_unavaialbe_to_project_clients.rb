class AddForceRemoveUnavaialbeToProjectClients < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :force_remove_unavailable_fors, :boolean, default: false
  end
end
