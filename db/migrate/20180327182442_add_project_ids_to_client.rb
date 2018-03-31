class AddProjectIdsToClient < ActiveRecord::Migration
  def change
    add_column :project_clients, :enrolled_project_ids, :jsonb
    add_column :clients, :enrolled_project_ids, :jsonb
  end
end
