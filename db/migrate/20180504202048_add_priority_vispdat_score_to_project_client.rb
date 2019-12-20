class AddPriorityVispdatScoreToProjectClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :vispdat_priority_score, :integer, default: 0
  end
end
