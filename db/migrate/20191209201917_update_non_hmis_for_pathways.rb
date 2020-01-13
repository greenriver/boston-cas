class UpdateNonHmisForPathways < ActiveRecord::Migration[4.2]
  def change
    # This is on client
    remove_column :non_hmis_assessments, :full_release_on_file

    add_column :non_hmis_assessments, :ssvf_eligible, :boolean, default: false
    add_column :non_hmis_assessments, :veteran_rrh_desired, :boolean, default: false
    add_column :non_hmis_assessments, :rrh_th_desired, :boolean, default: false
    add_column :non_hmis_assessments, :dv_rrh_desired, :boolean, default: false
    add_column :non_hmis_assessments, :income_total_annual, :integer, default: false
    add_column :non_hmis_assessments, :other_accessibility, :boolean, default: false
    add_column :non_hmis_assessments, :disabled_housing, :boolean, default: false
  end
end
