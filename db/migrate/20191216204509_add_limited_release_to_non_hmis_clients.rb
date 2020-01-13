class AddLimitedReleaseToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :limited_release_on_file, :boolean, null: false, default: false
  end
end
