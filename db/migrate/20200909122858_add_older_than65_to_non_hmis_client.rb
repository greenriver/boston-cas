class AddOlderThan65ToNonHmisClient < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :older_than_65, :boolean
    add_column :non_hmis_assessments, :older_than_65, :boolean
    add_column :project_clients, :older_than_65, :boolean
    add_column :clients, :older_than_65, :boolean
  end
end
