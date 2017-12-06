class AddAmiConfig < ActiveRecord::Migration
  def change
    add_column :configs, :ami, :integer, null: false, default: 66_600
  end
end
