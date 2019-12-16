class AddLimitedReleaseToNonHmisClients < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :limited_release_on_file, :boolean, null: false, default: false
  end
end
