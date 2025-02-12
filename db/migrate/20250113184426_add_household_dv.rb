class AddHouseholdDv < ActiveRecord::Migration[7.0]
  def change
    [
      :non_hmis_assessments,
      :project_clients,
      :clients,
    ].each do |table|
      add_column table, :household_dv_survivor, :boolean
    end
    [
      :project_clients,
      :clients,
    ].each do |table|
      add_column table, :disqualified_for_state_assistance, :boolean
    end
  end
end
