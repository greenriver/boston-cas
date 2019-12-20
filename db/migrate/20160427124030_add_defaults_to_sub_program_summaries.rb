class AddDefaultsToSubProgramSummaries < ActiveRecord::Migration[4.2]
  def up
    change_column_default :sub_programs, :matched, 0
    change_column_default :sub_programs, :in_progress, 0
    change_column_default :sub_programs, :vacancies, 0
  end
  def down
    change_column_default :sub_programs, :matched, nil
    change_column_default :sub_programs, :in_progress, nil
    change_column_default :sub_programs, :vacancies, nil
  end
end
