class AddClientColumnsForRules < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :assessment_name, :string
    add_column :project_clients, :assessment_name, :string
    add_column :clients, :assessment_name, :string
  end
end
