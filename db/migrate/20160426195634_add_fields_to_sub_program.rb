class AddFieldsToSubProgram < ActiveRecord::Migration
  def change
    add_column :sub_programs, :housed, :integer
    add_column :sub_programs, :in_progress, :integer
    add_column :sub_programs, :remain, :integer
  end
end
