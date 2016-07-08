class Prototype < ActiveRecord::Migration
  def change

    create_table :contacts do |t|
      t.string :email
      t.string :phone
      t.string :first_name
      t.string :last_name
      t.string :organization_name
      t.references :user, index: true, null: true #optionally associated with a user
      t.timestamps null: false
    end

    create_table :project_owners do |t|
      t.string :name
      t.string :abbreviation
      t.timestamps null: false
    end

    # tracks where a data record came from
    create_table :data_sources do |t|
      t.string :name
      t.references :project_owner, index: true, null: false
      t.timestamps null: false
    end

    # normalize federal program (matched)
    create_table :federal_programs do |t|
      t.string :name
      t.string :abbreviation
      t.timestamps null: false
    end

    # raw project data from an HMIS
    create_table :projects do |t|
      t.string :name
      t.string :project_type, null: false #lodging or service
      t.references :project_owner, index: true, null: false
      t.references :data_source, index: true
      t.references :federal_program
      t.timestamps null: false
    end


    # raw project program data for the project
    # association between a project and a federal program. a project
    # can belong to multiple programs
    create_table :project_programs do |t|
      t.string :entity_id
      t.references :project, index: true, null: false
      t.string :program_name #raw input (used to match to program)
      #t.string :partner_name #raw input
      t.timestamps null: false
    end


    # normalized client (matched)
    # has many project_clients for each instance of the client associated with
    # a project in a HMIS
    create_table :clients do |t|
      # HMIS 3.1 Name
      t.string :first_name
      t.string :middel_name
      t.string :last_name
      t.string :name_suffix
      t.string :name_quality, limit: 4

      # HMIS 3.2 Social Security Number
      t.string :ssn, limit: 9
      t.string :ssn_quality, limit: 4

      # HMIS 3.3 Date of Birth
      t.date :date_of_birth
      t.string :date_of_birth_quality, limit: 4

      #  HMIS 3.4 Race
      t.string :race, limit: 50

      #  HMIS 3.5 Ethnicity
      t.string :ethnicity, limit: 50

      # HMIS 3.6 Gender
      t.string :gender, limit: 50
      t.string :gender_other, limit: 50

      # HMIS 3.7 Veteran Status
      t.string :veteran_status, limit: 50
      t.boolean :veteran

      # HMIS 3.8 Disabling Condition
      t.string :disabling_condition, limit: 50

      # Derived from HMIS 3.17 limit of Time on Street, in an Emergency Shelter, or Safe Haven
      t.boolean :cronic_homeless

      # HMIS 4.2 Income and Sources
      # TODO: into new table -> client_income_assessments belongs to a clinet
      t.date :income_information_date
      t.string :income_from_any_source, limit: 20
      t.integer :income_total_montly
      t.boolean :income_earned
      t.boolean :income_unimployment
      t.boolean :income_ssi
      t.boolean :income_va_service
      t.boolean :income_va_non_service
      t.boolean :income_private_disability
      t.boolean :income_workers_comp
      t.boolean :income_tnaf
      t.boolean :income_general_assistance
      t.boolean :income_ss_retirement
      t.boolean :income_pension
      t.boolean :income_child_support
      t.boolean :income_spousal_support
      t.boolean :income_other
      t.string  :income_other_sources
      t.integer :income_earned_monthly
      t.integer :income_unimployment_monthly
      t.integer :income_ssi_monthly
      t.integer :income_va_service_monthly
      t.integer :income_va_non_service_monthly
      t.integer :income_private_disability_monthly
      t.integer :income_workers_comp_monthly
      t.integer :income_tnaf_monthly
      t.integer :income_general_assistance_monthly
      t.integer :income_ss_retirement_monthly
      t.integer :income_pension_monthly
      t.integer :income_child_support_monthly
      t.integer :income_spousal_support_monthly
      t.integer :income_other_monthly
      t.integer :income_total_monthly

      # HMIS 4.3 Non-Cash Benefits
      # TODO: into new table -> client_benefit_assessments belongs to a clinet
      t.date :non_cash_benefits_information_date
      t.string :non_cash_benefits, limit: 20
      t.boolean :snap
      t.boolean :wic
      t.boolean :tnaf_child_care
      t.boolean :tnaf_transportaion
      t.boolean :tnaf_other_benefit
      t.boolean :ongoing_rental_assistance
      t.boolean :other_benefit_sources
      t.boolean :temporary_rental_assistance

      # HMIS 4.4 Health Insurance
      # TODO: into new table -> client_health_insurance_assessments belongs to a clinet
      t.date :health_insurance_information_date
      t.string :health_insurance, limit: 4
      t.boolean :health_insurance_medicaid
      t.string :health_insurance_medicaid_reason, limit: 4
      t.boolean :health_insurance_medicare
      t.string :health_insurance_medicare_reason, limit: 4
      t.boolean :health_insurance_state_childrens
      t.string :health_insurance_state_childrens_reason, limit: 4
      t.boolean :health_insurance_va
      t.string :health_insurance_va_reason, limit: 4
      t.boolean :health_insurance_employer
      t.string :health_insurance_employer_reason, limit: 4
      t.boolean :health_insurance_cobra
      t.string :health_insurance_cobra_reason, limit: 4
      t.boolean :health_insurance_private_pay
      t.string :health_insurance_private_pay_reason, limit: 4
      t.boolean :health_insurance_state_adults
      t.string :health_insurance_state_adults_reason, limit: 4

      # Derived from HMIS 4.5 Physical Disability
      t.boolean :physical_disability

      # Derived from HMIS 4.6 Developmental Disability
      t.boolean :developmental_disability

      # Derived from HMIS 4.7 Chronic Health Condition
      t.boolean :cronic_health_problem

      # Derived from HMIS 4.8 HIV/AIDS
      t.boolean :hiv_aids

      # Derived from HMIS 4.9 Mental Health Problem
      t.boolean :mental_health_problem

      # Derived from HMIS 4.10 Substance Abuse
      t.boolean :substance_abuse_problem

      # Derived from HMIS 4.11 Domestic Violence
      t.boolean :domestic_violence

      # HMIS 4.14 C Services Provided
      # FIXME: join table

      # HMIS 4.19
      # FIXME: join table

      # HMIS 4.39 Medical Assistance
      # FIXME: join table

      t.timestamps null: false
    end

    # raw client data from a specific project in a HMIS
    create_table :project_clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :ssn
      t.date :date_of_birth
      t.string :veteran_status
      t.string :substance_abuse_problem
      t.references :data_source, index: true, null: false
      t.references :client, index: true, null: false
      t.references :project, index: true, null: false
      t.date :entry_date
      t.date :exit_date
      t.timestamps null: false
    end

    create_table :opportunities do |t|
      t.string :entity_id
      t.string :opportunity_type
      t.string :name
      t.boolean :available
      t.references :project, index: true, null: false
      t.timestamps null: false
    end

    create_table :opportunity_properties do |t|
      t.references :opportunity, index: true, null: false
      t.timestamps null: false
    end

    create_table :client_contacts do |t|
      #override info specific to a client
      # t.string :email
      # t.string :phone
      # t.string :first_name
      # t.string :last_name
      # t.string :organization_name
      t.references :client, index: true, null: false
      t.references :contact, index: true, null: false
      t.timestamps null: false
    end

    create_table :opportunity_contacts do |t|
      #override info specific to an opportunity
      # t.string :email
      # t.string :phone
      # t.string :first_name
      # t.string :last_name
      # t.string :organization_name
      t.references :opportunity, index: true, null: false
      t.references :contact, index: true, null: false
      t.timestamps null: false
    end

    create_table :project_contacts do |t|
      t.references :project, index: true, null: false
      t.references :contact, index: true, null: false
      t.timestamps null: false
    end

    create_table :client_opportunity_matches do |t|
      t.integer :score
      t.references :client, index: true, null: false
      t.references :opportunity, index: true, null: false
      t.references :contact, index: true
      t.datetime :proposed_at
      t.timestamps null: false
    end

    create_table :services do |t|
      t.string :name, null: false
      t.references :project, index: true
      t.references :opportunity, index: true
      t.references :contact, index: true
      t.timestamps null: false
    end

  end
end
