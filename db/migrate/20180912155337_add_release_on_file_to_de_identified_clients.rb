class AddReleaseOnFileToDeIdentifiedClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :full_release_on_file, :boolean, default: false, null: false
  end
end
