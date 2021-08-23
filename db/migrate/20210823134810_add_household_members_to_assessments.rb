class AddHouseholdMembersToAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :household_members, :jsonb
    add_column :non_hmis_assessments, :financial_assistance_end_date, :date
    add_column :non_hmis_assessments, :wait_times_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :not_matched_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :matched_process_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :response_time_ack, :boolean, null: false, default: false
    add_column :non_hmis_assessments, :automatic_approval_ack, :boolean, null: false, default: false
  end
end
