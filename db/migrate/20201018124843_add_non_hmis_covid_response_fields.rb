class AddNonHmisCovidResponseFields < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :email_addresses, :string
    add_column :non_hmis_assessments, :mailing_address, :string
    add_column :non_hmis_assessments, :day_locations, :text
    add_column :non_hmis_assessments, :night_locations, :text
    add_column :non_hmis_assessments, :other_contact, :text
    add_column :non_hmis_assessments, :household_size, :integer
    add_column :non_hmis_assessments, :hoh_age, :string
    add_column :non_hmis_assessments, :current_living_situation, :string
    add_column :non_hmis_clients, :ssn_refused, :boolean, default: false
    add_column :non_hmis_assessments, :pending_housing_placement_type, :string
    add_column :non_hmis_assessments, :pending_housing_placement_type_other, :string
    add_column :non_hmis_assessments, :maximum_possible_monthly_rent, :integer
    add_column :non_hmis_assessments, :possible_housing_situation, :string
    add_column :non_hmis_assessments, :possible_housing_situation_other, :string
    add_column :non_hmis_assessments, :no_rrh_desired_reason, :string
    add_column :non_hmis_assessments, :no_rrh_desired_reason_other, :string
    add_column :non_hmis_assessments, :provider_agency_preference, :jsonb
    add_column :non_hmis_assessments, :accessibility_other, :string
    add_column :non_hmis_assessments, :hiv_housing, :string
    add_column :non_hmis_assessments, :affordable_housing, :jsonb
    add_column :non_hmis_assessments, :high_covid_risk, :jsonb
    add_column :non_hmis_assessments, :service_need_indicators, :jsonb
    add_column :non_hmis_assessments, :medical_care_last_six_months, :integer
    add_column :non_hmis_assessments, :intensive_needs, :jsonb
    add_column :non_hmis_assessments, :intensive_needs_other, :string
    add_column :non_hmis_assessments, :background_check_issues, :jsonb
    add_column :non_hmis_assessments, :additional_homeless_nights, :integer
    add_column :non_hmis_assessments, :homeless_night_range, :string
    add_column :non_hmis_assessments, :notes, :text
  end
end
