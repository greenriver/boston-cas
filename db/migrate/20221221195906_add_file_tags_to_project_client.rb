class AddFileTagsToProjectClient < ActiveRecord::Migration[6.0]
  def change
    add_column :project_clients, :file_tags, :jsonb, default: {}
    add_column :clients, :file_tags, :jsonb, default: {}
  end
end
