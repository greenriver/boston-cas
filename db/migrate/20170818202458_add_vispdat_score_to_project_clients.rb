class AddVispdatScoreToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :vispdat_score, :integer
    add_column :clients, :vispdat_score, :integer
  end
end
