class AddDefaultContactToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_reference :non_hmis_clients, :contact
  end
end
