class AddServiceNeedColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :service_need, :boolean, :default => false
    add_column :project_clients, :service_need, :boolean, :default => false
    add_column :clients, :service_need, :boolean, :default => false
  end
end
