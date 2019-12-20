class FixColumnMisspelling < ActiveRecord::Migration[4.2]
  def change
    rename_column :clients, :middel_name, :middle_name
  end
end
