class AddAddressFieldsToOpportunity < ActiveRecord::Migration
  def change

    add_column :opportunities, :address, :string
    add_column :opportunities, :city, :string
    add_column :opportunities, :state, :string
    add_column :opportunities, :zip_code, :string

  end
end
