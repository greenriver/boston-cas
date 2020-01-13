class CreateNonHmisAssessment < ActiveRecord::Migration[4.2]
  def change
    create_table :non_hmis_assessments do |t|
      t.belongs_to :non_hmis_client
      t.string :type

      t.integer :assessment_score
      t.integer :days_homeless_in_the_last_three_years
      t.boolean :veteran, null: false, default: false
      t.boolean :rrh_desired, null: false, default: false
      t.boolean :youth_rrh_desired, null: false, default: false
      t.text :rrh_assessment_contact_info
      t.boolean :income_maximization_assistance_requested, null: false, default: false
      t.boolean :pending_subsidized_housing_placement, null: false, default: false
      t.boolean :full_release_on_file, null: false, default: false
      t.boolean :requires_wheelchair_accessibility, null: false, default: false
      t.integer :required_number_of_bedrooms
      t.integer :required_minimum_occupancy
      t.boolean :requires_elevator_access, null: false, default: false
      t.boolean :family_member, null: false, default: false
      t.integer :calculated_chronic_homelessness
      t.json :neighborhood_interests, null: false, default: []
      t.float :income_total_monthly
      t.boolean :disabling_condition, null: false, default: false
      t.boolean :physical_disability, null: false, default: false
      t.boolean :developmental_disability, null: false, default: false
      t.date :date_days_homeless_verified
      t.string :who_verified_days_homeless
      t.boolean :domestic_violence, null: false, default: false
      t.boolean :interested_in_set_asides, null: false, default: false
      t.string :set_asides_housing_status
      t.boolean :set_asides_resident
      t.string :shelter_name
      t.date :entry_date
      t.string :case_manager_contact_info
      t.string :phone_number
      t.boolean :have_tenant_voucher
      t.string :children_info
      t.boolean :studio_ok
      t.boolean :one_br_ok
      t.boolean :sro_ok
      t.boolean :fifty_five_plus
      t.boolean :sixty_two_plus
      t.string :voucher_agency
      t.boolean :interested_in_disabled_housing
      t.boolean :chronic_health_condition
      t.boolean :mental_health_problem
      t.boolean :substance_abuse_problem
      t.integer :vispdat_score
      t.integer :vispdat_priority_score

      t.timestamp :imported_timestamp
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
