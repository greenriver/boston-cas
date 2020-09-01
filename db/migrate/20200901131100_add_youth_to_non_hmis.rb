class AddYouthToNonHmis < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :is_currently_youth, :boolean, default: false, null: false
    add_column :project_clients, :is_currently_youth, :boolean, default: false, null: false
    add_column :clients, :is_currently_youth, :boolean, default: false, null: false
  end
end
