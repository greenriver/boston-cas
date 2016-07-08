class FixColumnMisspelling < ActiveRecord::Migration
  def change
    rename_column :clients, :middel_name, :middle_name
  end
end
