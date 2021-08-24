class AddHouseholdMembersToAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :household_members, :jsonb
    add_column :non_hmis_assessments, :financial_assistance_end_date, :date
    add_column :non_hmis_assessments, :wait_times_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :not_matched_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :matched_process_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :response_time_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :automatic_approval_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :times_moved, :string
    add_column :non_hmis_assessments, :health_severity, :string
    add_column :non_hmis_assessments, :ever_experienced_dv, :string
    add_column :non_hmis_assessments, :eviction_risk, :string
    add_column :non_hmis_assessments, :need_daily_assistance, :string
    add_column :non_hmis_assessments, :any_income, :string
    add_column :non_hmis_assessments, :income_source, :string
    add_column :non_hmis_assessments, :positive_relationship, :string
    add_column :non_hmis_assessments, :legal_concerns, :string
    add_column :non_hmis_assessments, :healthcare_coverage, :string
    add_column :non_hmis_assessments, :childcare, :string
    add_column :non_hmis_assessments, :setting, :string
    add_column :non_hmis_assessments, :outreach_name, :string
    add_column :non_hmis_assessments, :denial_required, :string

    create_table :outreach_histories do |t|
      t.references :non_hmis_client, null: false
      t.references :user, null: false
      t.string :outreach_name
      t.timestamps
    end
  end
end
