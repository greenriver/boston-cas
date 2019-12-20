class AddFieldsToSubProgram < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_programs, :housed, :integer
    add_column :sub_programs, :in_progress, :integer
    add_column :sub_programs, :remain, :integer
  end
end
