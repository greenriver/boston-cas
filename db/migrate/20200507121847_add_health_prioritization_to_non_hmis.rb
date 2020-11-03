class AddHealthPrioritizationToNonHmis < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :health_prioritized, :boolean, default: false
    add_column :non_hmis_clients, :health_prioritized, :boolean, default: false
  end
end
