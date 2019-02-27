class AddDVtoNonHmis < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :domestic_violence, :boolean, null: false, default: false
  end
end
