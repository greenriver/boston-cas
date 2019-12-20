class AddShelterExpirationToMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :shelter_expiration, :date, default: nil
  end
end
