class AddInterestedInDisabledHousingToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :interested_in_disabled_housing, :boolean
  end
end
