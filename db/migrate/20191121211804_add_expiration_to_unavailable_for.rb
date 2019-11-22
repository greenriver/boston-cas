class AddExpirationToUnavailableFor < ActiveRecord::Migration
  def change
    add_column :configs, :unavailable_for_length, :integer, default: 0
  end
end
