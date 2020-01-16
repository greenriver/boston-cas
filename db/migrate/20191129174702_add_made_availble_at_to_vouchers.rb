class AddMadeAvailbleAtToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :made_available_at, :datetime
  end
end
