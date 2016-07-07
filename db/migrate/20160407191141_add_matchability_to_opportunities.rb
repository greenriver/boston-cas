class AddMatchabilityToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :matchability, :float
  end
end
