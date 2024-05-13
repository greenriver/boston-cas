class AddPrioritizedClientColumns < ActiveRecord::Migration[7.0]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :ongoing_es_enrollments, :jsonb
      add_column table, :ongoing_so_enrollments, :jsonb
      add_column table, :last_seen_projects, :jsonb
    end
  end
end
