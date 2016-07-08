class AddVoucherToOpportunities < ActiveRecord::Migration
  def change
    add_reference :opportunities, :voucher, index: true, foreign_key: true
  end
end
