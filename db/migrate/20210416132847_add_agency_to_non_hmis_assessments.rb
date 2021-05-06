class AddAgencyToNonHmisAssessments < ActiveRecord::Migration[6.0]
  def change
    add_reference :non_hmis_assessments, :agency
  end
end
