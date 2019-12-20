class AddCustomExpirationTimeToMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :client_opportunity_matches, :custom_expiration_length, :integer
  end
end
