class AddPregnancyStatus < ActiveRecord::Migration
  def change
    add_column :clients, :pregnancy_status, :boolean, default: false
    add_column :project_clients, :pregnancy_status, :boolean, default: false
  end
end
