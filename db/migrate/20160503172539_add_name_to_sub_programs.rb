class AddNameToSubPrograms < ActiveRecord::Migration
  def change
    add_column :sub_programs, :name, :string
  end
end
