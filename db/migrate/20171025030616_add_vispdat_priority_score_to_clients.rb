class AddVispdatPriorityScoreToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :vispdat_priority_score, :integer, default: 0
  end
end
