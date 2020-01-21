class RemoveNullFalseFromNonHmisAssessments < ActiveRecord::Migration
  def change
    change_column_null :non_hmis_assessments, :pending_subsidized_housing_placement, true
    change_column_null :non_hmis_assessments, :domestic_violence, true
    change_column_null :non_hmis_assessments, :veteran, true
    change_column_null :non_hmis_assessments, :ssvf_eligible, true
    change_column_null :non_hmis_assessments, :veteran_rrh_desired, true
    change_column_null :non_hmis_assessments, :rrh_desired, true
    change_column_null :non_hmis_assessments, :sro_ok, true
    change_column_null :non_hmis_assessments, :required_number_of_bedrooms, true
    change_column_null :non_hmis_assessments, :disabled_housing, true
    change_column_null :non_hmis_assessments, :neighborhood_interests, true
  end
end
