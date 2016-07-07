class AddLastHomelessNightRoomidToProjectClients < ActiveRecord::Migration
  def change
    add_column :project_clients, :last_homeless_night_programid, :integer
    add_column :project_clients, :last_homeless_night_roomid, :integer
  end
end
