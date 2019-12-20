class FixNullRequirementsOnProjectClients < ActiveRecord::Migration[4.2]
  def change
    change_column_null :project_clients, :data_source_id, true
    change_column_null :project_clients, :client_id, true
    change_column_null :project_clients, :project_id, true
  end
end
