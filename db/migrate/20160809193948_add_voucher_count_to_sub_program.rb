class AddVoucherCountToSubProgram < ActiveRecord::Migration
  def change
    add_column :sub_programs, :voucher_count, :integer, default: 0
  end
end
