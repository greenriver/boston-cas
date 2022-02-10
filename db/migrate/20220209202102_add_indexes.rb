class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :clients, :available
    add_index :clients, :calculated_last_homeless_night
    add_index :clients, :days_homeless_in_last_three_years
    add_index :clients, :vispdat_score
    add_index :clients, :vispdat_priority_score
    add_index :clients, :enrolled_project_ids
    add_index :clients, :active_cohort_ids
    add_index :clients, :health_prioritized
    add_index :clients, :family_member
    add_index :clients, :disabling_condition
    add_index :clients, :date_of_birth
  end
end
