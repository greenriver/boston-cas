class AddCoriHearingRequiredColumnToSubProgram < ActiveRecord::Migration[7.0]
  def change
    add_column :sub_programs, :cori_hearing_required, :boolean
  end
end
