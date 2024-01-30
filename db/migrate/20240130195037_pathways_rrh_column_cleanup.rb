class PathwaysRrhColumnCleanup < ActiveRecord::Migration[6.1]
  def change
    remove_column :non_hmis_assessments, :interested_in_rapid_rehousing
  end
end
