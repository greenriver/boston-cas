class AddPshRequiredToClients < ActiveRecord::Migration[7.0]
  def change
    [:non_hmis_assessments, :non_hmis_clients, :project_clients, :clients].each do |table|
      add_column table, :psh_required, :string, default: 'maybe'
    end
  end
end
