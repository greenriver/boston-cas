class AddFirstHomelessNightToNonHmisAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :non_hmis_assessments, :calculated_first_homeless_night, :date
  end
end
