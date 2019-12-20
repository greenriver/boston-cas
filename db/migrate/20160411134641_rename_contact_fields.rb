class RenameContactFields < ActiveRecord::Migration[4.2]
  def change
    remove_column :contacts, :workphone, :string
    rename_column :contacts, :cellphone, :cell_phone
  end
end
