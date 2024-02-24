class AddHousingBarrierColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :housing_barrier, :boolean, :default => false
    add_column :project_clients, :housing_barrier, :boolean, :default => false
    add_column :clients, :housing_barrier, :boolean, :default => false
  end
end
