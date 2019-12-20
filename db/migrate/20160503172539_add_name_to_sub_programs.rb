class AddNameToSubPrograms < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_programs, :name, :string
  end
end
