class AddMatchabilityToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_column :opportunities, :matchability, :float
  end
end
