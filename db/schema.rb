# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_27_170803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.string "item_model"
    t.integer "item_id"
    t.string "title"
    t.integer "user_id", null: false
    t.string "controller_name", null: false
    t.string "action_name", null: false
    t.string "method"
    t.string "path"
    t.string "ip_address", null: false
    t.string "session_hash"
    t.text "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["controller_name"], name: "index_activity_logs_on_controller_name"
    t.index ["created_at", "item_model", "user_id"], name: "index_activity_logs_on_created_at_and_item_model_and_user_id"
    t.index ["created_at"], name: "activity_logs_created_at_idx", using: :brin
    t.index ["created_at"], name: "created_at_idx", using: :brin
    t.index ["item_model", "user_id", "created_at"], name: "index_activity_logs_on_item_model_and_user_id_and_created_at"
    t.index ["item_model", "user_id"], name: "index_activity_logs_on_item_model_and_user_id"
    t.index ["item_model"], name: "index_activity_logs_on_item_model"
    t.index ["user_id", "item_model", "created_at"], name: "index_activity_logs_on_user_id_and_item_model_and_created_at"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "agencies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "building_contacts", id: :serial, force: :cascade do |t|
    t.integer "building_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["building_id"], name: "index_building_contacts_on_building_id"
    t.index ["contact_id"], name: "index_building_contacts_on_contact_id"
    t.index ["deleted_at"], name: "index_building_contacts_on_deleted_at"
  end

  create_table "building_services", id: :serial, force: :cascade do |t|
    t.integer "building_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["building_id"], name: "index_building_services_on_building_id"
    t.index ["deleted_at"], name: "index_building_services_on_deleted_at"
    t.index ["service_id"], name: "index_building_services_on_service_id"
  end

  create_table "buildings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "building_type"
    t.integer "subgrantee_id"
    t.integer "id_in_data_source"
    t.integer "federal_program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "geo_code"
    t.index ["id_in_data_source"], name: "index_buildings_on_id_in_data_source"
    t.index ["subgrantee_id"], name: "index_buildings_on_subgrantee_id"
  end

  create_table "client_contacts", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "shelter_agency", default: false, null: false
    t.boolean "regular", default: false, null: false
    t.boolean "dnd_staff", default: false, null: false
    t.boolean "housing_subsidy_admin", default: false, null: false
    t.boolean "ssp", default: false, null: false
    t.boolean "hsp", default: false, null: false
    t.boolean "do", default: false, null: false
    t.index ["client_id"], name: "index_client_contacts_on_client_id"
    t.index ["contact_id"], name: "index_client_contacts_on_contact_id"
    t.index ["deleted_at"], name: "index_client_contacts_on_deleted_at"
  end

  create_table "client_notes", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
    t.string "note"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_opportunity_match_contacts", id: :serial, force: :cascade do |t|
    t.integer "match_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "dnd_staff", default: false, null: false
    t.boolean "housing_subsidy_admin", default: false, null: false
    t.boolean "client", default: false, null: false
    t.boolean "housing_search_worker", default: false, null: false
    t.boolean "shelter_agency", default: false, null: false
    t.boolean "ssp", default: false, null: false
    t.boolean "hsp", default: false, null: false
    t.boolean "do", default: false, null: false
    t.index ["contact_id"], name: "index_client_opportunity_match_contacts_on_contact_id"
    t.index ["deleted_at"], name: "index_client_opportunity_match_contacts_on_deleted_at"
    t.index ["match_id"], name: "index_client_opportunity_match_contacts_on_match_id"
  end

  create_table "client_opportunity_matches", id: :serial, force: :cascade do |t|
    t.integer "score"
    t.integer "client_id", null: false
    t.integer "opportunity_id", null: false
    t.integer "contact_id"
    t.datetime "proposed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "selected"
    t.boolean "active", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.string "closed_reason"
    t.json "universe_state"
    t.integer "custom_expiration_length"
    t.date "shelter_expiration"
    t.date "stall_date"
    t.datetime "stall_contacts_notified"
    t.datetime "dnd_notified"
    t.integer "match_route_id"
    t.index ["active"], name: "index_client_opportunity_matches_on_active"
    t.index ["client_id"], name: "index_client_opportunity_matches_on_client_id"
    t.index ["closed"], name: "index_client_opportunity_matches_on_closed"
    t.index ["closed_reason"], name: "index_client_opportunity_matches_on_closed_reason"
    t.index ["contact_id"], name: "index_client_opportunity_matches_on_contact_id"
    t.index ["deleted_at"], name: "index_client_opportunity_matches_on_deleted_at", where: "(deleted_at IS NULL)"
    t.index ["opportunity_id"], name: "index_client_opportunity_matches_on_opportunity_id"
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "name_suffix"
    t.string "name_quality", limit: 4
    t.string "ssn", limit: 9
    t.date "date_of_birth"
    t.string "gender_other", limit: 50
    t.boolean "veteran", default: false
    t.boolean "chronic_homeless", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "merged_into"
    t.integer "split_from"
    t.integer "ssn_quality"
    t.integer "date_of_birth_quality"
    t.integer "race_id"
    t.integer "ethnicity_id"
    t.integer "gender_id"
    t.integer "veteran_status_id"
    t.integer "developmental_disability"
    t.integer "domestic_violence"
    t.date "calculated_first_homeless_night"
    t.boolean "available", default: true, null: false
    t.string "homephone"
    t.string "cellphone"
    t.string "workphone"
    t.string "pager"
    t.string "email"
    t.boolean "hiv_aids", default: false
    t.boolean "chronic_health_problem", default: false
    t.boolean "mental_health_problem", default: false
    t.boolean "substance_abuse_problem", default: false
    t.boolean "physical_disability", default: false
    t.boolean "disabling_condition", default: false
    t.datetime "release_of_information"
    t.date "prevent_matching_until"
    t.boolean "dmh_eligible", default: false
    t.boolean "va_eligible", default: false, null: false
    t.boolean "hues_eligible", default: false, null: false
    t.datetime "disability_verified_on"
    t.datetime "housing_assistance_network_released_on"
    t.boolean "sync_with_cas", default: false, null: false
    t.float "income_total_monthly"
    t.datetime "income_total_monthly_last_collected"
    t.boolean "confidential", default: false, null: false
    t.boolean "hiv_positive", default: false, null: false
    t.string "housing_release_status"
    t.integer "vispdat_score"
    t.boolean "ineligible_immigrant", default: false, null: false
    t.boolean "family_member", default: false, null: false
    t.boolean "child_in_household", default: false, null: false
    t.boolean "us_citizen", default: false, null: false
    t.boolean "asylee", default: false, null: false
    t.boolean "lifetime_sex_offender", default: false, null: false
    t.boolean "meth_production_conviction", default: false, null: false
    t.integer "days_homeless"
    t.boolean "ha_eligible", default: false, null: false
    t.integer "days_homeless_in_last_three_years"
    t.integer "vispdat_priority_score", default: 0
    t.integer "vispdat_length_homeless_in_days", default: 0, null: false
    t.boolean "cspech_eligible", default: false
    t.string "alternate_names"
    t.date "calculated_last_homeless_night"
    t.boolean "congregate_housing", default: false
    t.boolean "sober_housing", default: false
    t.jsonb "enrolled_project_ids"
    t.jsonb "active_cohort_ids"
    t.string "client_identifier"
    t.integer "assessment_score", default: 0, null: false
    t.boolean "ssvf_eligible", default: false, null: false
    t.boolean "rrh_desired", default: false, null: false
    t.boolean "youth_rrh_desired", default: false, null: false
    t.string "rrh_assessment_contact_info"
    t.datetime "rrh_assessment_collected_at"
    t.boolean "enrolled_in_th", default: false, null: false
    t.boolean "enrolled_in_es", default: false, null: false
    t.boolean "enrolled_in_sh", default: false, null: false
    t.boolean "enrolled_in_so", default: false, null: false
    t.integer "days_literally_homeless_in_last_three_years", default: 0
    t.boolean "requires_wheelchair_accessibility", default: false
    t.integer "required_number_of_bedrooms", default: 1
    t.integer "required_minimum_occupancy", default: 1
    t.boolean "requires_elevator_access", default: false
    t.jsonb "neighborhood_interests", default: [], null: false
    t.date "date_days_homeless_verified"
    t.string "who_verified_days_homeless"
    t.float "tie_breaker"
    t.boolean "interested_in_set_asides", default: false
    t.jsonb "tags"
    t.string "case_manager_contact_info"
    t.boolean "vash_eligible"
    t.boolean "pregnancy_status", default: false
    t.boolean "income_maximization_assistance_requested", default: false
    t.boolean "pending_subsidized_housing_placement", default: false
    t.boolean "rrh_th_desired", default: false
    t.boolean "sro_ok", default: false
    t.boolean "evicted", default: false
    t.boolean "dv_rrh_desired", default: false
    t.boolean "health_prioritized", default: false
    t.boolean "is_currently_youth", default: false, null: false
    t.boolean "older_than_65"
    t.date "holds_voucher_on"
    t.boolean "holds_internal_cas_voucher"
    t.string "assessment_name"
    t.date "entry_date"
    t.date "financial_assistance_end_date"
    t.index ["deleted_at"], name: "index_clients_on_deleted_at"
  end

  create_table "configs", id: :serial, force: :cascade do |t|
    t.integer "dnd_interval", null: false
    t.string "warehouse_url", null: false
    t.boolean "require_cori_release", default: true
    t.integer "ami", default: 66600, null: false
    t.string "vispdat_prioritization_scheme", default: "length_of_time"
    t.text "non_hmis_fields"
    t.integer "unavailable_for_length", default: 0
    t.string "deidentified_client_assessment", default: "DeidentifiedClientAssessment"
    t.string "identified_client_assessment", default: "IdentifiedClientAssessment"
    t.integer "lock_days", default: 0, null: false
    t.integer "lock_grace_days", default: 0, null: false
    t.boolean "limit_client_names_on_matches", default: true
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "phone"
    t.string "first_name"
    t.string "last_name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "role"
    t.integer "id_in_data_source"
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.integer "role_id"
    t.string "role_in_organization"
    t.string "cell_phone"
    t.string "middle_name"
    t.index ["deleted_at"], name: "index_contacts_on_deleted_at"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "data_sources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "db_identifier"
    t.string "client_url"
  end

  create_table "date_of_birth_quality_codes", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deidentified_clients_xlsxes", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.integer "user_id"
    t.string "content_type"
    t.binary "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "file"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "disabling_conditions", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discharge_statuses", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "domestic_violence_survivors", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entity_view_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "entity_id", null: false
    t.string "entity_type", null: false
    t.boolean "editable"
    t.datetime "deleted_at"
    t.bigint "agency_id"
    t.index ["agency_id"], name: "index_entity_view_permissions_on_agency_id"
    t.index ["entity_type", "entity_id"], name: "index_entity_view_permissions_on_entity_type_and_entity_id"
    t.index ["user_id"], name: "index_entity_view_permissions_on_user_id"
  end

  create_table "ethnicities", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_tags", id: :serial, force: :cascade do |t|
    t.integer "sub_program_id", null: false
    t.string "name"
    t.integer "tag_id"
  end

  create_table "funding_source_services", id: :serial, force: :cascade do |t|
    t.integer "funding_source_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_funding_source_services_on_deleted_at"
    t.index ["funding_source_id"], name: "index_funding_source_services_on_funding_source_id"
    t.index ["service_id"], name: "index_funding_source_services_on_service_id"
  end

  create_table "funding_sources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "id_in_data_source"
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.datetime "deleted_at"
  end

  create_table "genders", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_developmental_disabilities", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_hivaids", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_mental_health_problems", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "helps", force: :cascade do |t|
    t.string "controller_path", null: false
    t.string "action_name", null: false
    t.string "external_url"
    t.string "title", null: false
    t.text "content", null: false
    t.string "location", default: "internal", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["controller_path", "action_name"], name: "index_helps_on_controller_path_and_action_name", unique: true
    t.index ["created_at"], name: "index_helps_on_created_at"
    t.index ["updated_at"], name: "index_helps_on_updated_at"
  end

  create_table "housing_attributes", force: :cascade do |t|
    t.string "housingable_type"
    t.bigint "housingable_id"
    t.string "name"
    t.string "value"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["housingable_type", "housingable_id"], name: "index_housing_attributes_on_housingable_type_and_housingable_id"
  end

  create_table "housing_media_links", force: :cascade do |t|
    t.string "housingable_type"
    t.bigint "housingable_id"
    t.string "label"
    t.string "url"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["housingable_type", "housingable_id"], name: "index_housing_media_links_on_housingable_type_and_id"
  end

  create_table "imported_clients_csvs", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.integer "user_id"
    t.string "content_type"
    t.string "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "file"
  end

  create_table "letsencrypt_plugin_challenges", id: :serial, force: :cascade do |t|
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "letsencrypt_plugin_settings", id: :serial, force: :cascade do |t|
    t.text "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "login_activities", id: :serial, force: :cascade do |t|
    t.string "scope"
    t.string "strategy"
    t.string "identity"
    t.boolean "success"
    t.string "failure_reason"
    t.integer "user_id"
    t.string "user_type"
    t.string "context"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "city"
    t.string "region"
    t.string "country"
    t.datetime "created_at"
    t.index ["identity"], name: "index_login_activities_on_identity"
    t.index ["ip"], name: "index_login_activities_on_ip"
  end

  create_table "match_census", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.integer "opportunity_id", null: false
    t.integer "match_id"
    t.string "program_name"
    t.string "sub_program_name"
    t.jsonb "prioritized_client_ids", default: [], null: false
    t.integer "active_client_id"
    t.jsonb "requirements", default: [], null: false
    t.integer "match_prioritization_id"
    t.integer "active_client_prioritization_value"
    t.string "prioritization_method_used"
    t.index ["date"], name: "index_match_census_on_date"
    t.index ["match_id"], name: "index_match_census_on_match_id"
    t.index ["match_prioritization_id"], name: "index_match_census_on_match_prioritization_id"
    t.index ["opportunity_id"], name: "index_match_census_on_opportunity_id"
  end

  create_table "match_decision_reasons", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "active", default: true, null: false
    t.boolean "ineligible_in_warehouse", default: false, null: false
    t.integer "referral_result"
    t.boolean "limited", default: false
    t.index ["type"], name: "index_match_decision_reasons_on_type"
  end

  create_table "match_decisions", id: :serial, force: :cascade do |t|
    t.integer "match_id"
    t.string "type"
    t.string "status"
    t.integer "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "client_last_seen_date"
    t.datetime "criminal_hearing_date"
    t.datetime "client_move_in_date"
    t.integer "decline_reason_id"
    t.text "decline_reason_other_explanation"
    t.integer "not_working_with_client_reason_id"
    t.text "not_working_with_client_reason_other_explanation"
    t.boolean "client_spoken_with_services_agency", default: false
    t.boolean "cori_release_form_submitted", default: false
    t.datetime "deleted_at"
    t.integer "administrative_cancel_reason_id"
    t.string "administrative_cancel_reason_other_explanation"
    t.date "application_date"
    t.boolean "disable_opportunity", default: false
    t.boolean "external_software_used", default: false, null: false
    t.string "address"
    t.index ["administrative_cancel_reason_id"], name: "index_match_decisions_on_administrative_cancel_reason_id"
    t.index ["decline_reason_id"], name: "index_match_decisions_on_decline_reason_id"
    t.index ["match_id"], name: "index_match_decisions_on_match_id"
    t.index ["not_working_with_client_reason_id"], name: "index_match_decisions_on_not_working_with_client_reason_id"
  end

  create_table "match_events", id: :serial, force: :cascade do |t|
    t.string "type"
    t.integer "match_id"
    t.integer "notification_id"
    t.integer "decision_id"
    t.integer "contact_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
    t.datetime "deleted_at"
    t.integer "not_working_with_client_reason_id"
    t.date "client_last_seen_date"
    t.boolean "admin_note", default: false, null: false
    t.integer "client_id"
    t.index ["decision_id"], name: "index_match_events_on_decision_id"
    t.index ["match_id"], name: "index_match_events_on_match_id"
    t.index ["not_working_with_client_reason_id"], name: "index_match_events_on_not_working_with_client_reason_id"
    t.index ["notification_id"], name: "index_match_events_on_notification_id"
  end

  create_table "match_mitigation_reasons", force: :cascade do |t|
    t.bigint "client_opportunity_match_id"
    t.bigint "mitigation_reason_id"
    t.boolean "addressed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_opportunity_match_id"], name: "index_match_mitigation_reasons_on_client_opportunity_match_id"
    t.index ["mitigation_reason_id"], name: "index_match_mitigation_reasons_on_mitigation_reason_id"
  end

  create_table "match_prioritizations", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.boolean "active", default: true, null: false
    t.integer "weight", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "match_progress_updates", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.integer "match_id", null: false
    t.integer "notification_id"
    t.integer "contact_id", null: false
    t.integer "decision_id"
    t.integer "notification_number"
    t.datetime "requested_at"
    t.datetime "submitted_at"
    t.datetime "dnd_notified_at"
    t.string "response"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.date "client_last_seen"
    t.index ["contact_id"], name: "index_match_progress_updates_on_contact_id"
    t.index ["decision_id"], name: "index_match_progress_updates_on_decision_id"
    t.index ["match_id"], name: "index_match_progress_updates_on_match_id"
    t.index ["notification_id"], name: "index_match_progress_updates_on_notification_id"
    t.index ["type"], name: "index_match_progress_updates_on_type"
  end

  create_table "match_routes", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.boolean "active", default: true, null: false
    t.integer "weight", default: 10, null: false
    t.boolean "contacts_editable_by_hsa", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stalled_interval", default: 7, null: false
    t.integer "match_prioritization_id", default: 5, null: false
    t.boolean "should_cancel_other_matches", default: true, null: false
    t.boolean "should_activate_match", default: true, null: false
    t.boolean "should_prevent_multiple_matches_per_client", default: true, null: false
    t.boolean "allow_multiple_active_matches", default: false, null: false
    t.boolean "default_shelter_agency_contacts_from_project_client", default: false, null: false
    t.integer "tag_id"
    t.boolean "show_default_contact_types", default: true
    t.boolean "send_notifications", default: true
    t.string "housing_type"
    t.boolean "send_notes_by_default", default: false, null: false
    t.index ["tag_id"], name: "index_match_routes_on_tag_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.string "from", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.boolean "html", default: false, null: false
    t.datetime "seen_at"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "contact_id", null: false
  end

  create_table "mitigation_reasons", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "name_quality_codes", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "neighborhood_interests", id: :serial, force: :cascade do |t|
    t.integer "client_id"
    t.integer "neighborhood_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "neighborhoods", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_hmis_assessments", id: :serial, force: :cascade do |t|
    t.integer "non_hmis_client_id"
    t.string "type"
    t.integer "assessment_score"
    t.integer "days_homeless_in_the_last_three_years"
    t.boolean "veteran", default: false
    t.boolean "rrh_desired", default: false
    t.boolean "youth_rrh_desired", default: false, null: false
    t.text "rrh_assessment_contact_info"
    t.boolean "income_maximization_assistance_requested", default: false, null: false
    t.boolean "pending_subsidized_housing_placement", default: false
    t.boolean "requires_wheelchair_accessibility", default: false, null: false
    t.integer "required_number_of_bedrooms"
    t.integer "required_minimum_occupancy"
    t.boolean "requires_elevator_access", default: false, null: false
    t.boolean "family_member", default: false, null: false
    t.integer "calculated_chronic_homelessness"
    t.json "neighborhood_interests", default: []
    t.float "income_total_monthly"
    t.boolean "disabling_condition", default: false, null: false
    t.boolean "physical_disability", default: false, null: false
    t.boolean "developmental_disability", default: false, null: false
    t.date "date_days_homeless_verified"
    t.string "who_verified_days_homeless"
    t.boolean "domestic_violence", default: false
    t.boolean "interested_in_set_asides", default: false, null: false
    t.string "set_asides_housing_status"
    t.boolean "set_asides_resident"
    t.string "shelter_name"
    t.date "entry_date"
    t.string "case_manager_contact_info"
    t.string "phone_number"
    t.boolean "have_tenant_voucher"
    t.string "children_info"
    t.boolean "studio_ok"
    t.boolean "one_br_ok"
    t.boolean "sro_ok"
    t.boolean "fifty_five_plus"
    t.boolean "sixty_two_plus"
    t.string "voucher_agency"
    t.boolean "interested_in_disabled_housing"
    t.boolean "chronic_health_condition"
    t.boolean "mental_health_problem"
    t.boolean "substance_abuse_problem"
    t.integer "vispdat_score"
    t.integer "vispdat_priority_score"
    t.datetime "imported_timestamp"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "ssvf_eligible", default: false
    t.boolean "veteran_rrh_desired", default: false
    t.boolean "rrh_th_desired", default: false
    t.boolean "dv_rrh_desired", default: false
    t.integer "income_total_annual", default: 0
    t.boolean "other_accessibility", default: false
    t.boolean "disabled_housing", default: false
    t.boolean "actively_homeless", default: false, null: false
    t.integer "user_id"
    t.boolean "evicted", default: false
    t.boolean "documented_disability", default: false
    t.boolean "health_prioritized", default: false
    t.boolean "hiv_aids", default: false
    t.boolean "is_currently_youth", default: false, null: false
    t.boolean "older_than_65"
    t.string "email_addresses"
    t.string "mailing_address"
    t.text "day_locations"
    t.text "night_locations"
    t.text "other_contact"
    t.integer "household_size"
    t.string "hoh_age"
    t.string "current_living_situation"
    t.string "pending_housing_placement_type"
    t.string "pending_housing_placement_type_other"
    t.integer "maximum_possible_monthly_rent"
    t.string "possible_housing_situation"
    t.string "possible_housing_situation_other"
    t.string "no_rrh_desired_reason"
    t.string "no_rrh_desired_reason_other"
    t.jsonb "provider_agency_preference"
    t.string "accessibility_other"
    t.string "hiv_housing"
    t.jsonb "affordable_housing"
    t.jsonb "high_covid_risk"
    t.jsonb "service_need_indicators"
    t.integer "medical_care_last_six_months"
    t.jsonb "intensive_needs"
    t.string "intensive_needs_other"
    t.jsonb "background_check_issues"
    t.integer "additional_homeless_nights"
    t.string "homeless_night_range"
    t.text "notes"
    t.string "veteran_status"
    t.bigint "agency_id"
    t.string "assessment_type"
    t.jsonb "household_members"
    t.date "financial_assistance_end_date"
    t.boolean "wait_times_ack", default: false, null: false
    t.boolean "not_matched_ack", default: false, null: false
    t.boolean "matched_process_ack", default: false, null: false
    t.boolean "response_time_ack", default: false, null: false
    t.boolean "automatic_approval_ack", default: false, null: false
    t.string "times_moved"
    t.string "health_severity"
    t.string "ever_experienced_dv"
    t.string "eviction_risk"
    t.string "need_daily_assistance"
    t.string "any_income"
    t.string "income_source"
    t.string "positive_relationship"
    t.string "legal_concerns"
    t.string "healthcare_coverage"
    t.string "childcare"
    t.string "setting"
    t.string "outreach_name"
    t.string "denial_required"
    t.date "locked_until"
    t.string "assessment_name"
    t.integer "hud_assessment_location"
    t.integer "hud_assessment_type"
    t.index ["agency_id"], name: "index_non_hmis_assessments_on_agency_id"
    t.index ["user_id"], name: "index_non_hmis_assessments_on_user_id"
  end

  create_table "non_hmis_clients", id: :serial, force: :cascade do |t|
    t.string "client_identifier"
    t.integer "assessment_score"
    t.string "deprecated_agency"
    t.string "first_name"
    t.string "last_name"
    t.jsonb "active_cohort_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "identified"
    t.date "date_of_birth"
    t.string "ssn"
    t.integer "days_homeless_in_the_last_three_years"
    t.boolean "veteran", default: false, null: false
    t.boolean "rrh_desired", default: false, null: false
    t.boolean "youth_rrh_desired", default: false, null: false
    t.text "rrh_assessment_contact_info"
    t.boolean "income_maximization_assistance_requested", default: false, null: false
    t.boolean "pending_subsidized_housing_placement", default: false, null: false
    t.boolean "full_release_on_file", default: false, null: false
    t.boolean "requires_wheelchair_accessibility", default: false, null: false
    t.integer "required_number_of_bedrooms", default: 1
    t.integer "required_minimum_occupancy", default: 1
    t.boolean "requires_elevator_access", default: false, null: false
    t.boolean "family_member", default: false, null: false
    t.string "middle_name"
    t.integer "calculated_chronic_homelessness"
    t.integer "gender"
    t.string "type"
    t.boolean "available", default: true, null: false
    t.date "date_days_homeless_verified"
    t.string "who_verified_days_homeless"
    t.json "neighborhood_interests", default: []
    t.float "income_total_monthly"
    t.boolean "disabling_condition", default: false
    t.boolean "physical_disability", default: false
    t.boolean "developmental_disability", default: false
    t.boolean "domestic_violence", default: false, null: false
    t.boolean "interested_in_set_asides", default: false
    t.jsonb "tags"
    t.datetime "imported_timestamp"
    t.string "set_asides_housing_status"
    t.boolean "set_asides_resident"
    t.string "shelter_name"
    t.date "entry_date"
    t.string "case_manager_contact_info"
    t.string "phone_number"
    t.string "email"
    t.boolean "have_tenant_voucher"
    t.string "children_info"
    t.boolean "studio_ok"
    t.boolean "one_br_ok"
    t.boolean "sro_ok"
    t.boolean "fifty_five_plus"
    t.boolean "sixty_two_plus"
    t.integer "warehouse_client_id"
    t.string "voucher_agency"
    t.boolean "interested_in_disabled_housing"
    t.boolean "chronic_health_condition"
    t.boolean "mental_health_problem"
    t.boolean "substance_abuse_problem"
    t.integer "agency_id"
    t.integer "contact_id"
    t.integer "vispdat_score", default: 0
    t.integer "vispdat_priority_score", default: 0
    t.boolean "actively_homeless", default: false, null: false
    t.boolean "limited_release_on_file", default: false, null: false
    t.boolean "active_client", default: true, null: false
    t.boolean "eligible_for_matching", default: true, null: false
    t.datetime "available_date"
    t.string "available_reason"
    t.boolean "is_currently_youth", default: false, null: false
    t.datetime "assessed_at"
    t.boolean "health_prioritized", default: false
    t.boolean "hiv_aids", default: false
    t.boolean "older_than_65"
    t.boolean "ssn_refused", default: false
    t.integer "race"
    t.integer "ethnicity"
    t.index ["deleted_at"], name: "index_non_hmis_clients_on_deleted_at"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_opportunity_match_id"
    t.integer "recipient_id"
    t.datetime "expires_at"
    t.boolean "include_content", default: true
  end

  create_table "opportunities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "available", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "unit_id"
    t.float "matchability"
    t.boolean "available_candidate", default: true
    t.integer "voucher_id"
    t.boolean "success", default: false
    t.index ["deleted_at"], name: "index_opportunities_on_deleted_at", where: "(deleted_at IS NULL)"
    t.index ["unit_id"], name: "index_opportunities_on_unit_id"
    t.index ["voucher_id"], name: "index_opportunities_on_voucher_id"
  end

  create_table "opportunity_contacts", id: :serial, force: :cascade do |t|
    t.integer "opportunity_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "housing_subsidy_admin", default: false, null: false
    t.index ["contact_id"], name: "index_opportunity_contacts_on_contact_id"
    t.index ["deleted_at"], name: "index_opportunity_contacts_on_deleted_at"
    t.index ["opportunity_id"], name: "index_opportunity_contacts_on_opportunity_id"
  end

  create_table "opportunity_properties", id: :serial, force: :cascade do |t|
    t.integer "opportunity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opportunity_id"], name: "index_opportunity_properties_on_opportunity_id"
  end

  create_table "outreach_histories", force: :cascade do |t|
    t.bigint "non_hmis_client_id", null: false
    t.bigint "user_id", null: false
    t.string "outreach_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["non_hmis_client_id"], name: "index_outreach_histories_on_non_hmis_client_id"
    t.index ["user_id"], name: "index_outreach_histories_on_user_id"
  end

  create_table "physical_disabilities", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "primary_races", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "program_contacts", id: :serial, force: :cascade do |t|
    t.integer "program_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "dnd_staff", default: false, null: false
    t.boolean "housing_subsidy_admin", default: false, null: false
    t.boolean "client", default: false, null: false
    t.boolean "housing_search_worker", default: false, null: false
    t.boolean "shelter_agency", default: false, null: false
    t.boolean "ssp", default: false, null: false
    t.boolean "hsp", default: false, null: false
    t.boolean "do", default: false, null: false
    t.index ["contact_id"], name: "index_program_contacts_on_contact_id"
    t.index ["program_id"], name: "index_program_contacts_on_program_id"
  end

  create_table "program_services", id: :serial, force: :cascade do |t|
    t.integer "program_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_program_services_on_deleted_at"
    t.index ["program_id"], name: "index_program_services_on_program_id"
    t.index ["service_id"], name: "index_program_services_on_service_id"
  end

  create_table "programs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "contract_start_date"
    t.integer "funding_source_id"
    t.integer "subgrantee_id"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "confidential", default: false, null: false
    t.integer "match_route_id", default: 1
    t.text "description"
    t.index ["contact_id"], name: "index_programs_on_contact_id"
    t.index ["deleted_at"], name: "index_programs_on_deleted_at"
    t.index ["funding_source_id"], name: "index_programs_on_funding_source_id"
    t.index ["subgrantee_id"], name: "index_programs_on_subgrantee_id"
  end

  create_table "project_clients", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "ssn"
    t.date "date_of_birth"
    t.string "veteran_status"
    t.string "substance_abuse_problem"
    t.date "entry_date"
    t.date "exit_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "clientguid"
    t.string "middle_name"
    t.integer "ssn_quality_code"
    t.integer "dob_quality_code"
    t.string "primary_race"
    t.string "secondary_race"
    t.integer "gender"
    t.integer "ethnicity"
    t.integer "disabling_condition"
    t.integer "hud_chronic_homelessness"
    t.integer "calculated_chronic_homelessness"
    t.integer "chronic_health_condition"
    t.integer "physical_disability"
    t.integer "hivaids_status"
    t.integer "mental_health_problem"
    t.integer "domestic_violence"
    t.integer "discharge_type"
    t.integer "developmental_disability"
    t.boolean "us_citizen", default: false, null: false
    t.boolean "asylee", default: false, null: false
    t.boolean "lifetime_sex_offender", default: false, null: false
    t.boolean "meth_production_conviction", default: false, null: false
    t.integer "id_in_data_source"
    t.date "calculated_first_homeless_night"
    t.date "calculated_last_homeless_night"
    t.datetime "source_last_changed"
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.integer "client_id"
    t.string "homephone"
    t.string "cellphone"
    t.string "workphone"
    t.string "pager"
    t.string "email"
    t.boolean "dmh_eligible", default: false
    t.boolean "va_eligible", default: false, null: false
    t.boolean "hues_eligible", default: false, null: false
    t.datetime "disability_verified_on"
    t.datetime "housing_assistance_network_released_on"
    t.boolean "sync_with_cas", default: false, null: false
    t.float "income_total_monthly"
    t.datetime "income_total_monthly_last_collected"
    t.boolean "hiv_positive", default: false, null: false
    t.string "housing_release_status"
    t.boolean "needs_update", default: false, null: false
    t.integer "vispdat_score"
    t.boolean "ineligible_immigrant", default: false, null: false
    t.boolean "family_member", default: false, null: false
    t.boolean "child_in_household", default: false, null: false
    t.integer "days_homeless"
    t.boolean "ha_eligible", default: false, null: false
    t.integer "days_homeless_in_last_three_years"
    t.integer "vispdat_length_homeless_in_days", default: 0, null: false
    t.boolean "cspech_eligible", default: false
    t.string "alternate_names"
    t.boolean "congregate_housing", default: false
    t.boolean "sober_housing", default: false
    t.jsonb "enrolled_project_ids"
    t.jsonb "active_cohort_ids"
    t.string "client_identifier"
    t.integer "vispdat_priority_score", default: 0
    t.integer "assessment_score", default: 0, null: false
    t.boolean "ssvf_eligible", default: false, null: false
    t.boolean "rrh_desired", default: false, null: false
    t.boolean "youth_rrh_desired", default: false, null: false
    t.string "rrh_assessment_contact_info"
    t.datetime "rrh_assessment_collected_at"
    t.boolean "enrolled_in_th", default: false, null: false
    t.boolean "enrolled_in_es", default: false, null: false
    t.boolean "enrolled_in_sh", default: false, null: false
    t.boolean "enrolled_in_so", default: false, null: false
    t.integer "days_literally_homeless_in_last_three_years", default: 0
    t.boolean "requires_wheelchair_accessibility", default: false
    t.integer "required_number_of_bedrooms", default: 1
    t.integer "required_minimum_occupancy", default: 1
    t.boolean "requires_elevator_access", default: false
    t.jsonb "neighborhood_interests", default: [], null: false
    t.date "date_days_homeless_verified"
    t.string "who_verified_days_homeless"
    t.boolean "interested_in_set_asides", default: false
    t.jsonb "default_shelter_agency_contacts"
    t.jsonb "tags"
    t.string "case_manager_contact_info"
    t.string "non_hmis_client_identifier"
    t.boolean "vash_eligible"
    t.boolean "pregnancy_status", default: false
    t.boolean "income_maximization_assistance_requested", default: false
    t.boolean "pending_subsidized_housing_placement", default: false
    t.boolean "rrh_th_desired", default: false
    t.boolean "sro_ok", default: false
    t.boolean "evicted", default: false
    t.boolean "dv_rrh_desired", default: false
    t.boolean "health_prioritized", default: false
    t.boolean "is_currently_youth", default: false, null: false
    t.boolean "older_than_65"
    t.date "holds_voucher_on"
    t.string "assessment_name"
    t.date "financial_assistance_end_date"
    t.index ["calculated_chronic_homelessness"], name: "index_project_clients_on_calculated_chronic_homelessness"
    t.index ["client_id"], name: "index_project_clients_on_client_id"
    t.index ["date_of_birth"], name: "index_project_clients_on_date_of_birth"
    t.index ["source_last_changed"], name: "index_project_clients_on_source_last_changed"
  end

  create_table "project_programs", id: :serial, force: :cascade do |t|
    t.string "id_in_data_source"
    t.string "program_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
  end

  create_table "reissue_requests", id: :serial, force: :cascade do |t|
    t.integer "notification_id"
    t.integer "reissued_by"
    t.datetime "reissued_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "request_sent_at"
    t.index ["deleted_at"], name: "index_reissue_requests_on_deleted_at"
    t.index ["notification_id"], name: "index_reissue_requests_on_notification_id"
    t.index ["reissued_by"], name: "index_reissue_requests_on_reissued_by"
  end

  create_table "rejected_matches", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "opportunity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["client_id"], name: "index_rejected_matches_on_client_id"
    t.index ["opportunity_id"], name: "index_rejected_matches_on_opportunity_id"
  end

  create_table "report_definitions", force: :cascade do |t|
    t.string "report_group"
    t.string "url"
    t.string "name", null: false
    t.string "description"
    t.integer "weight", default: 0, null: false
    t.boolean "enabled", default: true, null: false
    t.boolean "limitable", default: true
  end

  create_table "reporting_decisions", force: :cascade do |t|
    t.integer "client_id"
    t.integer "match_id", null: false
    t.integer "decision_id", null: false
    t.integer "decision_order", null: false
    t.string "match_step", null: false
    t.string "decision_status", null: false
    t.boolean "current_step", default: false, null: false
    t.boolean "active_match", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "elapsed_days", null: false
    t.datetime "client_last_seen_date"
    t.datetime "criminal_hearing_date"
    t.string "decline_reason"
    t.string "not_working_with_client_reason"
    t.string "administrative_cancel_reason"
    t.boolean "client_spoken_with_services_agency"
    t.boolean "cori_release_form_submitted"
    t.datetime "match_started_at"
    t.string "program_type"
    t.json "shelter_agency_contacts"
    t.json "hsa_contacts"
    t.json "ssp_contacts"
    t.json "admin_contacts"
    t.json "client_contacts"
    t.json "hsp_contacts"
    t.string "program_name", null: false
    t.string "sub_program_name", null: false
    t.string "terminal_status"
    t.string "match_route", null: false
    t.integer "cas_client_id", null: false
    t.date "client_move_in_date"
    t.string "source_data_source"
    t.string "event_contact"
    t.string "event_contact_agency"
    t.integer "vacancy_id", null: false
    t.string "housing_type"
    t.boolean "ineligible_in_warehouse", default: false, null: false
    t.string "actor_type"
    t.index ["client_id", "match_id", "decision_id"], name: "index_reporting_decisions_c_m_d", unique: true
  end

  create_table "requirements", id: :serial, force: :cascade do |t|
    t.integer "rule_id"
    t.integer "requirer_id"
    t.string "requirer_type"
    t.boolean "positive"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "variable"
    t.index ["deleted_at"], name: "index_requirements_on_deleted_at"
    t.index ["requirer_type", "requirer_id"], name: "index_requirements_on_requirer_type_and_requirer_id"
    t.index ["rule_id"], name: "index_requirements_on_rule_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "can_view_all_clients", default: false
    t.boolean "can_edit_all_clients", default: false
    t.boolean "can_participate_in_matches", default: false
    t.boolean "can_view_all_matches", default: false
    t.boolean "can_see_alternate_matches", default: false
    t.boolean "can_edit_match_contacts", default: false
    t.boolean "can_approve_matches", default: false
    t.boolean "can_reject_matches", default: false
    t.boolean "can_act_on_behalf_of_match_contacts", default: false
    t.boolean "can_view_reports", default: false
    t.boolean "can_edit_roles", default: false
    t.boolean "can_edit_users", default: false
    t.boolean "can_view_full_ssn", default: false
    t.boolean "can_view_full_dob", default: false
    t.boolean "can_view_buildings", default: false
    t.boolean "can_edit_buildings", default: false
    t.boolean "can_view_funding_sources", default: false
    t.boolean "can_edit_funding_sources", default: false
    t.boolean "can_view_subgrantees", default: false
    t.boolean "can_edit_subgrantees", default: false
    t.boolean "can_view_vouchers", default: false
    t.boolean "can_edit_vouchers", default: false
    t.boolean "can_view_programs", default: false
    t.boolean "can_edit_programs", default: false
    t.boolean "can_view_opportunities", default: false
    t.boolean "can_edit_opportunities", default: false
    t.boolean "can_reissue_notifications", default: false
    t.boolean "can_view_units", default: false
    t.boolean "can_edit_units", default: false
    t.boolean "can_add_vacancies", default: false
    t.boolean "can_view_contacts", default: false
    t.boolean "can_edit_contacts", default: false
    t.boolean "can_view_rule_list", default: false
    t.boolean "can_edit_rule_list", default: false
    t.boolean "can_view_available_services", default: false
    t.boolean "can_edit_available_services", default: false
    t.boolean "can_assign_services", default: false
    t.boolean "can_assign_requirements", default: false
    t.boolean "can_view_dmh_eligibility", default: false
    t.boolean "can_view_va_eligibility", default: false, null: false
    t.boolean "can_view_hues_eligibility", default: false, null: false
    t.boolean "can_become_other_users", default: false
    t.boolean "can_view_client_confidentiality", default: false, null: false
    t.boolean "can_view_hiv_positive_eligibility", default: false
    t.boolean "can_view_own_closed_matches", default: false
    t.boolean "can_edit_translations", default: false
    t.boolean "can_view_vspdats", default: false
    t.boolean "can_manage_config", default: false
    t.boolean "can_create_overall_note", default: false
    t.boolean "can_enter_deidentified_clients", default: false
    t.boolean "can_manage_deidentified_clients", default: false
    t.boolean "can_add_cohorts_to_deidentified_clients", default: false
    t.boolean "can_delete_client_notes", default: false
    t.boolean "can_enter_identified_clients", default: false
    t.boolean "can_manage_identified_clients", default: false
    t.boolean "can_add_cohorts_to_identified_clients", default: false
    t.boolean "can_manage_neighborhoods", default: false
    t.boolean "can_view_assigned_programs", default: false
    t.boolean "can_edit_assigned_programs", default: false
    t.boolean "can_export_deidentified_clients", default: false
    t.boolean "can_export_identified_clients", default: false
    t.boolean "can_manage_tags", default: false
    t.boolean "can_manage_imported_clients", default: false
    t.boolean "can_edit_clients_based_on_rules", default: false
    t.boolean "can_send_notes_via_email", default: false
    t.boolean "can_upload_deidentified_clients", default: false
    t.boolean "can_delete_matches", default: false
    t.boolean "can_reopen_matches", default: false
    t.boolean "can_see_all_alternate_matches", default: false
    t.boolean "can_edit_help", default: false
    t.boolean "can_audit_users", default: false
    t.boolean "can_view_all_covid_pathways", default: false
    t.boolean "can_manage_sessions", default: false
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "rules", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "type"
    t.string "verb"
    t.string "alternate_name"
    t.index ["deleted_at"], name: "index_rules_on_deleted_at"
  end

  create_table "secondary_races", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_rules", id: :serial, force: :cascade do |t|
    t.integer "rule_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_service_rules_on_deleted_at"
    t.index ["rule_id"], name: "index_service_rules_on_rule_id"
    t.index ["service_id"], name: "index_service_rules_on_service_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shelter_histories", force: :cascade do |t|
    t.bigint "non_hmis_client_id", null: false
    t.bigint "user_id", null: false
    t.string "shelter_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["non_hmis_client_id"], name: "index_shelter_histories_on_non_hmis_client_id"
    t.index ["user_id"], name: "index_shelter_histories_on_user_id"
  end

  create_table "social_security_number_quality_codes", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stalled_responses", id: :serial, force: :cascade do |t|
    t.boolean "client_engaging", default: true, null: false
    t.string "reason", null: false
    t.string "decision_type", null: false
    t.boolean "requires_note", default: false, null: false
    t.boolean "active", default: true, null: false
    t.integer "weight", default: 0, null: false
  end

  create_table "sub_program_contacts", force: :cascade do |t|
    t.bigint "sub_program_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.boolean "dnd_staff", default: false, null: false
    t.boolean "housing_subsidy_admin", default: false, null: false
    t.boolean "client", default: false, null: false
    t.boolean "housing_search_worker", default: false, null: false
    t.boolean "shelter_agency", default: false, null: false
    t.boolean "ssp", default: false, null: false
    t.boolean "hsp", default: false, null: false
    t.boolean "do", default: false, null: false
    t.index ["contact_id"], name: "index_sub_program_contacts_on_contact_id"
    t.index ["sub_program_id"], name: "index_sub_program_contacts_on_sub_program_id"
  end

  create_table "sub_programs", id: :serial, force: :cascade do |t|
    t.string "program_type"
    t.integer "program_id"
    t.integer "building_id"
    t.integer "subgrantee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "matched", default: 0
    t.integer "in_progress", default: 0
    t.integer "vacancies", default: 0
    t.string "name"
    t.integer "sub_contractor_id"
    t.integer "hsa_id"
    t.integer "voucher_count", default: 0
    t.boolean "confidential", default: false, null: false
    t.text "eligibility_requirement_notes"
    t.boolean "closed", default: false
    t.integer "event"
    t.index ["building_id"], name: "index_sub_programs_on_building_id"
    t.index ["deleted_at"], name: "index_sub_programs_on_deleted_at"
    t.index ["program_id"], name: "index_sub_programs_on_program_id"
    t.index ["subgrantee_id"], name: "index_sub_programs_on_subgrantee_id"
  end

  create_table "subgrantee_contacts", id: :serial, force: :cascade do |t|
    t.integer "subgrantee_id", null: false
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["contact_id"], name: "index_subgrantee_contacts_on_contact_id"
    t.index ["deleted_at"], name: "index_subgrantee_contacts_on_deleted_at"
    t.index ["subgrantee_id"], name: "index_subgrantee_contacts_on_subgrantee_id"
  end

  create_table "subgrantee_services", id: :serial, force: :cascade do |t|
    t.integer "subgrantee_id"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_subgrantee_services_on_deleted_at"
    t.index ["service_id"], name: "index_subgrantee_services_on_service_id"
    t.index ["subgrantee_id"], name: "index_subgrantee_services_on_subgrantee_id"
  end

  create_table "subgrantees", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "id_in_data_source"
    t.integer "disabled"
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.datetime "deleted_at"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean "rrh_assessment_trigger", default: false, null: false
  end

  create_table "translation_keys", id: :serial, force: :cascade do |t|
    t.string "key", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "index_translation_keys_on_key"
  end

  create_table "translation_texts", id: :serial, force: :cascade do |t|
    t.text "text"
    t.string "locale"
    t.integer "translation_key_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translation_key_id"], name: "index_translation_texts_on_translation_key_id"
  end

  create_table "unavailable_as_candidate_fors", id: :serial, force: :cascade do |t|
    t.integer "client_id", null: false
    t.string "match_route_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.index ["client_id"], name: "index_unavailable_as_candidate_fors_on_client_id"
    t.index ["match_route_type"], name: "index_unavailable_as_candidate_fors_on_match_route_type"
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.integer "id_in_data_source"
    t.string "name"
    t.boolean "available"
    t.string "target_population_a"
    t.string "target_population_b"
    t.boolean "mc_kinney_vento"
    t.integer "chronic"
    t.integer "veteran"
    t.integer "adult_only"
    t.integer "family"
    t.integer "child_only"
    t.integer "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "data_source_id"
    t.string "data_source_id_column_name"
    t.boolean "elevator_accessible", default: false, null: false
    t.index ["building_id"], name: "index_units_on_building_id"
    t.index ["deleted_at"], name: "index_units_on_deleted_at", where: "(deleted_at IS NULL)"
    t.index ["id_in_data_source"], name: "index_units_on_id_in_data_source"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.boolean "receive_initial_notification", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "email_schedule", default: "immediate", null: false
    t.boolean "active", default: true, null: false
    t.string "deprecated_agency"
    t.integer "agency_id"
    t.boolean "exclude_from_directory", default: false
    t.boolean "exclude_phone_from_directory", default: false
    t.string "unique_session_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.integer "user_id"
    t.string "session_id"
    t.string "request_id"
    t.string "notification_code"
    t.text "object_changes"
    t.integer "referenced_user_id"
    t.string "referenced_entity_name"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "veteran_statuses", id: :serial, force: :cascade do |t|
    t.integer "numeric"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vouchers", id: :serial, force: :cascade do |t|
    t.boolean "available"
    t.date "date_available"
    t.integer "sub_program_id"
    t.integer "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "user_id"
    t.datetime "made_available_at"
    t.index ["deleted_at"], name: "index_vouchers_on_deleted_at"
    t.index ["sub_program_id"], name: "index_vouchers_on_sub_program_id"
    t.index ["unit_id"], name: "index_vouchers_on_unit_id"
  end

  add_foreign_key "non_hmis_assessments", "users"
  add_foreign_key "opportunities", "vouchers"
  add_foreign_key "programs", "contacts"
  add_foreign_key "programs", "funding_sources"
  add_foreign_key "programs", "subgrantees"
  add_foreign_key "reissue_requests", "notifications"
  add_foreign_key "reissue_requests", "users", column: "reissued_by"
  add_foreign_key "sub_programs", "buildings"
  add_foreign_key "sub_programs", "programs"
  add_foreign_key "sub_programs", "subgrantees"
  add_foreign_key "sub_programs", "subgrantees", column: "hsa_id"
  add_foreign_key "sub_programs", "subgrantees", column: "sub_contractor_id"
  add_foreign_key "user_roles", "roles", on_delete: :cascade
  add_foreign_key "user_roles", "users", on_delete: :cascade
  add_foreign_key "vouchers", "sub_programs"
  add_foreign_key "vouchers", "units"
  add_foreign_key "vouchers", "users"
end
