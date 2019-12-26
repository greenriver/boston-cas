class AddPregnancyStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :pregnancy_status, :boolean, default: false
    add_column :project_clients, :pregnancy_status, :boolean, default: false
  end
end
