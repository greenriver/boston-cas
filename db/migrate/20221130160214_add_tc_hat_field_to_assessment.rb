class AddTcHatFieldToAssessment < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :ongoing_case_management_required, :boolean, default: false
  end
end
