class RenameContactFields < ActiveRecord::Migration
  def change
    remove_column :contacts, :workphone, :string
    rename_column :contacts, :cellphone, :cell_phone
  end
end
