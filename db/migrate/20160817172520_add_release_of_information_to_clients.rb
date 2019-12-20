class AddReleaseOfInformationToClients < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :release_of_information, :datetime
  end
end
