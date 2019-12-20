class RemoveProjectOwnerIdFromDataSources < ActiveRecord::Migration[4.2]
  def change
    remove_column :data_sources, :project_owner_id, :integer
    remove_column :project_programs, :project_id, :integer
  end
end
