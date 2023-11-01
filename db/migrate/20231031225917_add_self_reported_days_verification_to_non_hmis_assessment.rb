class AddSelfReportedDaysVerificationToNonHmisAssessment < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :self_reported_days_verified, :boolean, default: false
  end
end
