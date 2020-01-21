class AddUserToNonHmisAssessment < ActiveRecord::Migration
  def change
    add_reference :non_hmis_assessments, :user, index: true, foreign_key: true
  end
end
