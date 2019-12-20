class AddAmiConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :configs, :ami, :integer, null: false, default: 66_600
  end
end
