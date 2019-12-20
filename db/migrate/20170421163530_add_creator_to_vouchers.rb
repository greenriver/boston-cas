class AddCreatorToVouchers < ActiveRecord::Migration[4.2]
  def change
    add_reference :vouchers, :user, foreign_key: true,  column: :creator_id
  end
end
