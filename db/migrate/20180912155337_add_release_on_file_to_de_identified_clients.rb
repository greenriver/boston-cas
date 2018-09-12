class AddReleaseOnFileToDeIdentifiedClients < ActiveRecord::Migration
  def change
    add_column :deidentified_clients, :full_release_on_file, :boolean, default: false, null: false
  end
end
