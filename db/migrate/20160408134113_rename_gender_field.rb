class RenameGenderField < ActiveRecord::Migration[4.2]
  def change
    rename_column :clients, :gender, :gender_id
  end
end
