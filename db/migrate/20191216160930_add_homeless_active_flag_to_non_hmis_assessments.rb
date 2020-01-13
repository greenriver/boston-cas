class AddHomelessActiveFlagToNonHmisAssessments < ActiveRecord::Migration[4.2]
  def change
    add_column :non_hmis_assessments, :actively_homeless, :boolean, default: false, null: false
  end
end
