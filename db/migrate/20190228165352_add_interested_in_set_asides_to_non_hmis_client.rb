class AddInterestedInSetAsidesToNonHmisClient < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :interested_in_set_asides, :boolean, default: false
  end
end
