class AddInterestedInDisabledHousingToNonHmisClients < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :interested_in_disabled_housing, :boolean
  end
end
