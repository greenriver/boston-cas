class AddInterestedInSetAsidesToClient < ActiveRecord::Migration
  def change
    add_column :clients, :interested_in_set_asides, :boolean, default: false
  end
end
