class AddInterestedInSetAsidesToProjectClient < ActiveRecord::Migration[4.2]
  def change
    add_column :project_clients, :interested_in_set_asides, :boolean, default: false
  end
end
