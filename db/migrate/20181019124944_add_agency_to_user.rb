class AddAgencyToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :agency, :string
  end
end
