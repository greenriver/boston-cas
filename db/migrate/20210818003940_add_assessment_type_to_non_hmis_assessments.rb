class AddAssessmentTypeToNonHmisAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :assessment_type, :string
  end
end
