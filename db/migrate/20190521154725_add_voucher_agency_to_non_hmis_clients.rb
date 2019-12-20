class AddVoucherAgencyToNonHmisClients < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_clients, :voucher_agency, :string
  end
end
