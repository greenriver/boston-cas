class AddShelterExpirationToMatch < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :shelter_expiration, :date, default: nil
  end
end
