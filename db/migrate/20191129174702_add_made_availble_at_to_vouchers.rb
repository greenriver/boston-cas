class AddMadeAvailbleAtToVouchers < ActiveRecord::Migration[4.2]
  def change
    add_column :vouchers, :made_available_at, :datetime
  end
end
