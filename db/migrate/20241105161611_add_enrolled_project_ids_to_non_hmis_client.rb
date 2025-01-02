class AddEnrolledProjectIdsToNonHmisClient < ActiveRecord::Migration[7.0]
  def change
    add_column :non_hmis_clients, :enrolled_project_ids, :jsonb
  end
end
