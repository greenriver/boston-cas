class RemoveAvailableCandidateFromClients < ActiveRecord::Migration[4.2]
  def change
    remove_column :clients, :available_candidate, :boolean, default: true, null: false
  end
end
