class SplitHomelessDaysOnPathways < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :additional_homeless_nights_sheltered, :integer, default: 0
    add_column :non_hmis_assessments, :homeless_nights_sheltered, :integer, default: 0
    add_column :non_hmis_assessments, :additional_homeless_nights_unsheltered, :integer, default: 0
    add_column :non_hmis_assessments, :homeless_nights_unsheltered, :integer, default: 0
  end
end
