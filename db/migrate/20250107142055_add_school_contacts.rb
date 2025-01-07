class AddSchoolContacts < ActiveRecord::Migration[7.0]
  def change
    [
      :non_hmis_assessments,
      :project_clients,
      :clients,
    ].each do |table|
      add_column table, :requires_vision_or_hearing_accessibility, :boolean, default: false
    end

    add_column :non_hmis_assessments, :schools, :string
    add_column :non_hmis_assessments, :schools_contact_info, :text
    add_column :non_hmis_assessments, :disqualified_for_state_assistance, :boolean, default: false
    add_column :non_hmis_assessments, :disqualified_for_state_assistance_reasons, :string

  end
end
