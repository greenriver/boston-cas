class AddExpirationToUnavailableFor < ActiveRecord::Migration[4.2]
  def change
    add_column :configs, :unavailable_for_length, :integer, default: 0
  end
end
