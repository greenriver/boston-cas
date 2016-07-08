class RenameGenderField < ActiveRecord::Migration
  def change
    rename_column :clients, :gender, :gender_id
  end
end
