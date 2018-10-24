class AddAgencyToUser < ActiveRecord::Migration
  def change
    add_column :users, :agency, :string
  end
end
