class AddCreatorToVouchers < ActiveRecord::Migration
  def change
    add_reference :vouchers, :user, foreign_key: true,  column: :creator_id
  end
end
