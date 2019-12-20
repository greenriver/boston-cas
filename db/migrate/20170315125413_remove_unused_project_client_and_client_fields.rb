class RemoveUnusedProjectClientAndClientFields < ActiveRecord::Migration[4.2]
  # These columns were added early on, and are better seen in the warehouse
  def change
    remove_column :clients, :income_information_date, :date
    remove_column :clients, :income_from_any_source, :string, limit: 20
    remove_column :clients, :income_total_montly, :integer
    remove_column :clients, :income_earned, :boolean
    remove_column :clients, :income_unimployment, :boolean
    remove_column :clients, :income_ssi, :boolean
    remove_column :clients, :income_va_service, :boolean
    remove_column :clients, :income_va_non_service, :boolean
    remove_column :clients, :income_private_disability, :boolean
    remove_column :clients, :income_workers_comp, :boolean
    remove_column :clients, :income_tnaf, :boolean
    remove_column :clients, :income_general_assistance, :boolean
    remove_column :clients, :income_ss_retirement, :boolean
    remove_column :clients, :income_pension, :boolean
    remove_column :clients, :income_child_support, :boolean
    remove_column :clients, :income_spousal_support, :boolean
    remove_column :clients, :income_other, :boolean
    remove_column :clients, :income_other_sources, :string
    remove_column :clients, :income_earned_monthly, :integer
    remove_column :clients, :income_unimployment_monthly, :integer
    remove_column :clients, :income_ssi_monthly, :integer
    remove_column :clients, :income_va_service_monthly, :integer
    remove_column :clients, :income_va_non_service_monthly, :integer
    remove_column :clients, :income_private_disability_monthly, :integer
    remove_column :clients, :income_workers_comp_monthly, :integer
    remove_column :clients, :income_tnaf_monthly, :integer
    remove_column :clients, :income_general_assistance_monthly, :integer
    remove_column :clients, :income_ss_retirement_monthly, :integer
    remove_column :clients, :income_pension_monthly, :integer
    remove_column :clients, :income_child_support_monthly, :integer
    remove_column :clients, :income_spousal_support_monthly, :integer
    remove_column :clients, :income_other_monthly, :integer
    remove_column :clients, :income_total_monthly, :integer
    remove_column :clients, :non_cash_benefits_information_date, :date
    remove_column :clients, :non_cash_benefits, :string, limit: 20
    remove_column :clients, :snap, :boolean
    remove_column :clients, :wic, :boolean
    remove_column :clients, :tnaf_child_care, :boolean
    remove_column :clients, :tnaf_transportaion, :boolean
    remove_column :clients, :tnaf_other_benefit, :boolean
    remove_column :clients, :ongoing_rental_assistance, :boolean
    remove_column :clients, :other_benefit_sources, :boolean
    remove_column :clients, :temporary_rental_assistance, :boolean
    remove_column :clients, :health_insurance_information_date, :date
    remove_column :clients, :health_insurance, :string, limit: 4
    remove_column :clients, :health_insurance_medicaid, :boolean
    remove_column :clients, :health_insurance_medicaid_reason, :string, limit: 4
    remove_column :clients, :health_insurance_medicare, :boolean
    remove_column :clients, :health_insurance_medicare_reason, :string, limit: 4
    remove_column :clients, :health_insurance_state_childrens, :boolean
    remove_column :clients, :health_insurance_state_childrens_reason, :string, limit: 4
    remove_column :clients, :health_insurance_va, :boolean
    remove_column :clients, :health_insurance_va_reason, :string, limit: 4
    remove_column :clients, :health_insurance_employer, :boolean
    remove_column :clients, :health_insurance_employer_reason, :string, limit: 4
    remove_column :clients, :health_insurance_cobra, :boolean
    remove_column :clients, :health_insurance_cobra_reason, :string, limit: 4
    remove_column :clients, :health_insurance_private_pay, :boolean
    remove_column :clients, :health_insurance_private_pay_reason, :string, limit: 4
    remove_column :clients, :health_insurance_state_adults, :boolean
    remove_column :clients, :health_insurance_state_adults_reason, :string, limit: 4


    remove_column :project_clients, :on_parole, :boolean
    remove_column :project_clients, :on_parole_end_date, :date
    remove_column :project_clients, :on_probation, :boolean
    remove_column :project_clients, :on_probation_end_date, :date
    remove_column :project_clients, :income_total_monthly, :float
    remove_column :project_clients, :income_total_monthly_last_collected, :datetime
    remove_column :project_clients, :calculated_bed_nights_in_last_three_years, :integer
    remove_column :project_clients, :calculated_episodes_in_last_three_years, :integer
    remove_column :project_clients, :calculated_months_continously_homeless_in_last_three_years, :integer
    remove_column :project_clients, :reported_episodes_in_last_three_years, :string
    remove_column :project_clients, :reported_continuously_homeless_for_last_year, :string
    remove_column :project_clients, :reported_months_homeless_in_last_three_years, :string
    remove_column :project_clients, :reported_months_continuously_homeless_immediately_prior, :string
    remove_column :project_clients, :reported_months_continuously_homeless_documented, :string
    remove_column :project_clients, :project_exit_destination, :string
    remove_column :project_clients, :project_exit_destination_specific, :string
    remove_column :project_clients, :project_exit_destination_generic, :string
    remove_column :project_clients, :project_exit_housing_disposition, :string
    remove_column :project_clients, :old_warehouse_id, :string
    remove_column :project_clients, :last_homeless_night_programid, :integer
    remove_column :project_clients, :last_homeless_night_roomid, :integer
  end
end
