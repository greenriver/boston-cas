class AddUserToNonHmisAssessment < ActiveRecord::Migration[4.2]
  def change
    add_reference :non_hmis_assessments, :user, index: true, foreign_key: true
  end
end
