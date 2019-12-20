class AddVoucherCountToSubProgram < ActiveRecord::Migration[4.2]
  def up
    add_column :sub_programs, :voucher_count, :integer, default: 0
    sp = SubProgram.all
    sp.each do |s|
      if s.vouchers.count > 0
        s.update_attribute(:voucher_count, s.vouchers.count)
      end
    end

  end

  def down
    remove_column :sub_programs, :voucher_count
  end
end
