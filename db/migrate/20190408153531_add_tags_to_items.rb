class AddTagsToItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :match_routes, :tag, index: true
    add_column :non_hmis_clients, :tags, :jsonb
    add_column :project_clients, :tags, :jsonb
    add_column :clients, :tags, :jsonb
  end
end
