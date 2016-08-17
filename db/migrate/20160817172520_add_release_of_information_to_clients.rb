class AddReleaseOfInformationToClients < ActiveRecord::Migration
  def change
    add_column :clients, :release_of_information, :datetime
  end
end
