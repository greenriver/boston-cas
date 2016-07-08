class FixFieldsToSubProgram < ActiveRecord::Migration
  def change
    rename_column :sub_programs, :housed, :matched
    rename_column :sub_programs, :remain, :vacancies
  end
end
