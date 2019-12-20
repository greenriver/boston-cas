class AddSelectedToClientOpportunityMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :selected, :boolean
  end
end
