class AddSelectedToClientOpportunityMatch < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :selected, :boolean
  end
end
