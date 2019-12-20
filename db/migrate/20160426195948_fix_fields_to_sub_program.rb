class FixFieldsToSubProgram < ActiveRecord::Migration[4.2]
  def change
    rename_column :sub_programs, :housed, :matched
    rename_column :sub_programs, :remain, :vacancies
  end
end
