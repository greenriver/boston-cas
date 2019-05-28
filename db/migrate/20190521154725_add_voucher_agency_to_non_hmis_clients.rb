class AddVoucherAgencyToNonHmisClients < ActiveRecord::Migration
  def change
    add_column :non_hmis_clients, :voucher_agency, :string
  end
end
