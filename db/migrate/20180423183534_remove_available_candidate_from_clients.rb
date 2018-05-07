class RemoveAvailableCandidateFromClients < ActiveRecord::Migration
  def change
    remove_column :clients, :available_candidate, :boolean, default: true, null: false
  end
end
