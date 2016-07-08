class AddFlagsToClientsAndOpportunities < ActiveRecord::Migration
  def change
    add_column :clients, :available_candidate, :boolean, default: true, is_null: false
    add_column :opportunities, :available_candidate, :boolean, default: true, is_null: false
  end
end
