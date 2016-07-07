class AddSiteIdToProjectOwners < ActiveRecord::Migration
  def change
    add_column :project_owners, :site_id, :integer
    add_column :project_owners, :disabled, :integer
  end
end
