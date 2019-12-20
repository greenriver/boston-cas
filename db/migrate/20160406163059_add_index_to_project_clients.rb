class AddIndexToProjectClients < ActiveRecord::Migration[4.2]
  def change
    add_index :project_clients, :source_last_changed
    add_index :project_clients, :calculated_chronic_homelessness
    add_index :project_clients, :date_of_birth
  end
end
