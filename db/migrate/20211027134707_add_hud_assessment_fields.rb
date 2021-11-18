class AddHudAssessmentFields < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :hud_assessment_location, :integer
    add_column :non_hmis_assessments, :hud_assessment_type, :integer
  end
end
