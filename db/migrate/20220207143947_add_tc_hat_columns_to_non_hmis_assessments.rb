class AddTcHatColumnsToNonHmisAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :tc_hat_assessment_level, :integer
    add_column :non_hmis_assessments, :tc_hat_household_type, :string
    add_column :non_hmis_assessments, :ongoing_support_reason, :text
    add_column :non_hmis_assessments, :ongoing_support_housing_type, :string
    add_column :non_hmis_assessments, :strengths, :jsonb
    add_column :non_hmis_assessments, :challenges, :jsonb
    add_column :non_hmis_assessments, :lifetime_sex_offender, :boolean, default: false
    add_column :non_hmis_assessments, :state_id, :boolean, default: false
    add_column :non_hmis_assessments, :birth_certificate, :boolean, default: false
    add_column :non_hmis_assessments, :social_security_card, :boolean, default: false
    add_column :non_hmis_assessments, :has_tax_id, :boolean, default: false
    add_column :non_hmis_assessments, :tax_id, :string
    add_column :non_hmis_assessments, :roommate_ok, :boolean, default: false
    add_column :non_hmis_assessments, :full_time_employed, :boolean, default: false
    add_column :non_hmis_assessments, :can_work_full_time, :boolean, default: false
    add_column :non_hmis_assessments, :willing_to_work_full_time, :boolean, default: false
    add_column :non_hmis_assessments, :why_not_working, :string
    add_column :non_hmis_assessments, :rrh_successful_exit, :boolean, default: false
    add_column :non_hmis_assessments, :th_desired, :boolean, default: false
    add_column :non_hmis_assessments, :drug_test, :boolean, default: false
    add_column :non_hmis_assessments, :heavy_drug_use, :boolean, default: false
    add_column :non_hmis_assessments, :sober, :boolean, default: false
    add_column :non_hmis_assessments, :willing_case_management, :boolean, default: false
    add_column :non_hmis_assessments, :employed_three_months, :boolean, default: false
    add_column :non_hmis_assessments, :living_wage, :boolean, default: false
    add_column :non_hmis_assessments, :site_case_management_required, :boolean, default: false
    add_column :non_hmis_assessments, :tc_hat_client_history, :jsonb
    add_column :non_hmis_assessments, :open_case, :boolean, default: false
    add_column :non_hmis_assessments, :foster_care, :boolean, default: false
    add_column :non_hmis_assessments, :currently_fleeing, :boolean, default: false
    add_column :non_hmis_assessments, :dv_date, :date
    add_column :non_hmis_assessments, :tc_hat_ed_visits, :boolean, default: false

    add_column :non_hmis_assessments, :tc_hat_hospitalizations, :boolean, default: false
    add_column :non_hmis_assessments, :sixty_plus, :boolean, default: false
    add_column :non_hmis_assessments, :cirrhosis, :boolean, default: false
    add_column :non_hmis_assessments, :end_stage_renal_disease, :boolean, default: false
    add_column :non_hmis_assessments, :heat_stroke, :boolean, default: false
    add_column :non_hmis_assessments, :blind, :boolean, default: false
    add_column :non_hmis_assessments, :tri_morbidity, :boolean, default: false
    add_column :non_hmis_assessments, :high_potential_for_victimization, :boolean, default: false
    add_column :non_hmis_assessments, :self_harm, :boolean, default: false
    add_column :non_hmis_assessments, :medical_condition, :boolean, default: false
    add_column :non_hmis_assessments, :psychiatric_condition, :boolean, default: false
    add_column :non_hmis_assessments, :housing_preferences, :jsonb
    add_column :non_hmis_assessments, :housing_preferences_other, :string
    add_column :non_hmis_assessments, :housing_rejected_preferences, :jsonb
    add_column :non_hmis_assessments, :tc_hat_apartment, :integer
    add_column :non_hmis_assessments, :tc_hat_tiny_home, :integer
    add_column :non_hmis_assessments, :tc_hat_rv, :integer
    add_column :non_hmis_assessments, :tc_hat_house, :integer
    add_column :non_hmis_assessments, :tc_hat_mobile_home, :integer
    add_column :non_hmis_assessments, :tc_hat_total_housing_rank, :integer
  end
end
