class CreateReportingDecisions < ActiveRecord::Migration[6.0]
  def change
    create_table :reporting_decisions do |t|
      t.integer :client_id
      t.integer :match_id, null: false
      t.integer :decision_id, null: false
      t.integer :decision_order, null: false
      t.string :match_step, null: false
      t.string :decision_status, null: false
      t.boolean :current_step, null: false, default: false
      t.boolean :active_match, null: false, default: false
      t.timestamp :created_at, null: false
      t.timestamp :updated_at, null: false
      t.integer :elapsed_days, null: false
      t.timestamp :client_last_seen_date
      t.timestamp :criminal_hearing_date
      t.string :decline_reason
      t.string :not_working_with_client_reason
      t.string :administrative_cancel_reason
      t.boolean :client_spoken_with_services_agency
      t.boolean :cori_release_form_submitted
      t.timestamp :match_started_at
      t.string :program_type
      t.json :shelter_agency_contacts
      t.json :hsa_contacts
      t.json :ssp_contacts
      t.json :admin_contacts
      t.json :client_contacts
      t.json :hsp_contacts
      t.string :program_name, null: false
      t.string :sub_program_name, null: false
      t.string :terminal_status
      t.string :match_route, null: false
      t.integer :cas_client_id, null: false
      t.date :client_move_in_date
      t.string :source_data_source, null: false
      t.string :event_contact
      t.string :event_contact_agency
      t.integer :vacancy_id, null: false
      t.string :housing_type

      t.index [:client_id, :match_id, :decision_id], unique: true, name: :index_reporting_decisions_c_m_d
    end
  end
end
