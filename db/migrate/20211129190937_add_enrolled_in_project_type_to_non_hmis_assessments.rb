class AddEnrolledInProjectTypeToNonHmisAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :enrolled_in_es, :boolean, default: false, null: false
    add_column :non_hmis_assessments, :enrolled_in_so, :boolean, default: false, null: false
  end
end
