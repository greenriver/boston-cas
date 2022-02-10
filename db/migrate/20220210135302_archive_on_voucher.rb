class ArchiveOnVoucher < ActiveRecord::Migration[6.0]
  def change
    add_column :vouchers, :archived_at, :datetime
  end
end
