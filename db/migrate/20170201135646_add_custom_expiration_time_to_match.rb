class AddCustomExpirationTimeToMatch < ActiveRecord::Migration
  def change
    add_column :client_opportunity_matches, :custom_expiration_length, :integer
  end
end
