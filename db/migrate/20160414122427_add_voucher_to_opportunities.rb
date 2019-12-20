class AddVoucherToOpportunities < ActiveRecord::Migration[4.2]
  def change
    add_reference :opportunities, :voucher, index: true, foreign_key: true
  end
end
