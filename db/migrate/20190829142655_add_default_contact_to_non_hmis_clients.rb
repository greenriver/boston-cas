class AddDefaultContactToNonHmisClients < ActiveRecord::Migration
  def change
    add_reference :non_hmis_clients, :contact
  end
end
