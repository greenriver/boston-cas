class AddStaffContactsToNonHmisAssessments < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :staff_name, :string
    add_column :non_hmis_assessments, :staff_email, :string
  end
end
