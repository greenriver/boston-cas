class AddHomelessActiveFlagToNonHmisAssessments < ActiveRecord::Migration
  def change
    add_column :non_hmis_assessments, :actively_homeless, :boolean, default: false, null: false
  end
end
