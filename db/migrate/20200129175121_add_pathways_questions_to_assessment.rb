class AddPathwaysQuestionsToAssessment < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :evicted, :boolean, default: false
    add_column :non_hmis_assessments, :documented_disability, :boolean, default: false
  end
end
