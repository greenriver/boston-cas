class AddInterestedInSetAsidesToNonHmisClient < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :interested_in_set_asides, :boolean, default: false
  end
end
