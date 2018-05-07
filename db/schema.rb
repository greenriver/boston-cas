# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180505235920) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "building_contacts", force: :cascade do |t|
    t.integer  "building_id", null: false
    t.integer  "contact_id",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
  end

  add_index "building_contacts", ["building_id"], name: "index_building_contacts_on_building_id", using: :btree
  add_index "building_contacts", ["contact_id"], name: "index_building_contacts_on_contact_id", using: :btree
  add_index "building_contacts", ["deleted_at"], name: "index_building_contacts_on_deleted_at", using: :btree

  create_table "building_services", force: :cascade do |t|
    t.integer  "building_id"
    t.integer  "service_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
  end

  add_index "building_services", ["building_id"], name: "index_building_services_on_building_id", using: :btree
  add_index "building_services", ["deleted_at"], name: "index_building_services_on_deleted_at", using: :btree
  add_index "building_services", ["service_id"], name: "index_building_services_on_service_id", using: :btree

  create_table "buildings", force: :cascade do |t|
    t.string   "name"
    t.string   "building_type"
    t.integer  "subgrantee_id"
    t.integer  "id_in_data_source"
    t.integer  "federal_program_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "geo_code"
  end

  add_index "buildings", ["id_in_data_source"], name: "index_buildings_on_id_in_data_source", using: :btree
  add_index "buildings", ["subgrantee_id"], name: "index_buildings_on_subgrantee_id", using: :btree

  create_table "client_contacts", force: :cascade do |t|
    t.integer  "client_id",                      null: false
    t.integer  "contact_id",                     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "deleted_at"
    t.boolean  "shelter_agency", default: false, null: false
    t.boolean  "regular",        default: false, null: false
  end

  add_index "client_contacts", ["client_id"], name: "index_client_contacts_on_client_id", using: :btree
  add_index "client_contacts", ["contact_id"], name: "index_client_contacts_on_contact_id", using: :btree
  add_index "client_contacts", ["deleted_at"], name: "index_client_contacts_on_deleted_at", using: :btree

  create_table "client_opportunity_match_contacts", force: :cascade do |t|
    t.integer  "match_id",                              null: false
    t.integer  "contact_id",                            null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
    t.boolean  "dnd_staff",             default: false, null: false
    t.boolean  "housing_subsidy_admin", default: false, null: false
    t.boolean  "client",                default: false, null: false
    t.boolean  "housing_search_worker", default: false, null: false
    t.boolean  "shelter_agency",        default: false, null: false
    t.boolean  "ssp",                   default: false, null: false
    t.boolean  "hsp",                   default: false, null: false
  end

  add_index "client_opportunity_match_contacts", ["contact_id"], name: "index_client_opportunity_match_contacts_on_contact_id", using: :btree
  add_index "client_opportunity_match_contacts", ["deleted_at"], name: "index_client_opportunity_match_contacts_on_deleted_at", using: :btree
  add_index "client_opportunity_match_contacts", ["match_id"], name: "index_client_opportunity_match_contacts_on_match_id", using: :btree

  create_table "client_opportunity_matches", force: :cascade do |t|
    t.integer  "score"
    t.integer  "client_id",                                null: false
    t.integer  "opportunity_id",                           null: false
    t.integer  "contact_id"
    t.datetime "proposed_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "deleted_at"
    t.boolean  "selected"
    t.boolean  "active",                   default: false, null: false
    t.boolean  "closed",                   default: false, null: false
    t.string   "closed_reason"
    t.json     "universe_state"
    t.integer  "custom_expiration_length"
    t.date     "shelter_expiration"
  end

  add_index "client_opportunity_matches", ["active"], name: "index_client_opportunity_matches_on_active", using: :btree
  add_index "client_opportunity_matches", ["client_id"], name: "index_client_opportunity_matches_on_client_id", using: :btree
  add_index "client_opportunity_matches", ["closed"], name: "index_client_opportunity_matches_on_closed", using: :btree
  add_index "client_opportunity_matches", ["closed_reason"], name: "index_client_opportunity_matches_on_closed_reason", using: :btree
  add_index "client_opportunity_matches", ["contact_id"], name: "index_client_opportunity_matches_on_contact_id", using: :btree
  add_index "client_opportunity_matches", ["deleted_at"], name: "index_client_opportunity_matches_on_deleted_at", where: "(deleted_at IS NULL)", using: :btree
  add_index "client_opportunity_matches", ["opportunity_id"], name: "index_client_opportunity_matches_on_opportunity_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "name_suffix"
    t.string   "name_quality",                           limit: 4
    t.string   "ssn",                                    limit: 9
    t.date     "date_of_birth"
    t.string   "gender_other",                           limit: 50
    t.boolean  "veteran",                                           default: false
    t.boolean  "chronic_homeless",                                  default: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.datetime "deleted_at"
    t.integer  "merged_into"
    t.integer  "split_from"
    t.integer  "ssn_quality"
    t.integer  "date_of_birth_quality"
    t.integer  "race_id"
    t.integer  "ethnicity_id"
    t.integer  "gender_id"
    t.integer  "veteran_status_id"
    t.integer  "developmental_disability"
    t.integer  "domestic_violence"
    t.date     "calculated_first_homeless_night"
    t.boolean  "available",                                         default: true,  null: false
    t.string   "homephone"
    t.string   "cellphone"
    t.string   "workphone"
    t.string   "pager"
    t.string   "email"
    t.boolean  "hiv_aids",                                          default: false
    t.boolean  "chronic_health_problem",                            default: false
    t.boolean  "mental_health_problem",                             default: false
    t.boolean  "substance_abuse_problem",                           default: false
    t.boolean  "physical_disability",                               default: false
    t.boolean  "disabling_condition",                               default: false
    t.datetime "release_of_information"
    t.date     "prevent_matching_until"
    t.boolean  "dmh_eligible",                                      default: false
    t.boolean  "va_eligible",                                       default: false, null: false
    t.boolean  "hues_eligible",                                     default: false, null: false
    t.datetime "disability_verified_on"
    t.datetime "housing_assistance_network_released_on"
    t.boolean  "sync_with_cas",                                     default: false, null: false
    t.float    "income_total_monthly"
    t.datetime "income_total_monthly_last_collected"
    t.boolean  "confidential",                                      default: false, null: false
    t.boolean  "hiv_positive",                                      default: false, null: false
    t.string   "housing_release_status"
    t.integer  "vispdat_score"
    t.boolean  "ineligible_immigrant",                              default: false, null: false
    t.boolean  "family_member",                                     default: false, null: false
    t.boolean  "child_in_household",                                default: false, null: false
    t.boolean  "us_citizen",                                        default: false, null: false
    t.boolean  "asylee",                                            default: false, null: false
    t.boolean  "lifetime_sex_offender",                             default: false, null: false
    t.boolean  "meth_production_conviction",                        default: false, null: false
    t.integer  "days_homeless"
    t.boolean  "ha_eligible",                                       default: false, null: false
    t.integer  "days_homeless_in_last_three_years"
    t.integer  "vispdat_priority_score",                            default: 0
    t.integer  "vispdat_length_homeless_in_days",                   default: 0,     null: false
    t.boolean  "cspech_eligible",                                   default: false
    t.string   "alternate_names"
    t.date     "calculated_last_homeless_night"
    t.boolean  "congregate_housing",                                default: false
    t.boolean  "sober_housing",                                     default: false
    t.jsonb    "enrolled_project_ids"
    t.jsonb    "active_cohort_ids"
    t.string   "client_identifier"
    t.integer  "assessment_score",                                  default: 0,     null: false
  end

  add_index "clients", ["deleted_at"], name: "index_clients_on_deleted_at", using: :btree

  create_table "configs", force: :cascade do |t|
    t.integer "dnd_interval",                         null: false
    t.string  "warehouse_url",                        null: false
    t.boolean "require_cori_release", default: true
    t.integer "ami",                  default: 66600, null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "email"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
    t.string   "role"
    t.integer  "id_in_data_source"
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
    t.integer  "role_id"
    t.string   "role_in_organization"
    t.string   "cell_phone"
    t.string   "middle_name"
  end

  add_index "contacts", ["deleted_at"], name: "index_contacts_on_deleted_at", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "data_sources", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "db_identifier"
  end

  create_table "date_of_birth_quality_codes", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deidentified_clients", force: :cascade do |t|
    t.string   "client_identifier"
    t.integer  "assessment_score"
    t.string   "agency"
    t.string   "first_name",        default: "Anonymous"
    t.string   "last_name",         default: "Anonymous"
    t.jsonb    "active_cohort_ids"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "deleted_at"
  end

  add_index "deidentified_clients", ["deleted_at"], name: "index_deidentified_clients_on_deleted_at", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "disabling_conditions", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discharge_statuses", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "domestic_violence_survivors", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ethnicities", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "file_tags", force: :cascade do |t|
    t.integer "sub_program_id", null: false
    t.string  "name"
    t.integer "tag_id"
  end

  create_table "funding_source_services", force: :cascade do |t|
    t.integer  "funding_source_id"
    t.integer  "service_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
  end

  add_index "funding_source_services", ["deleted_at"], name: "index_funding_source_services_on_deleted_at", using: :btree
  add_index "funding_source_services", ["funding_source_id"], name: "index_funding_source_services_on_funding_source_id", using: :btree
  add_index "funding_source_services", ["service_id"], name: "index_funding_source_services_on_service_id", using: :btree

  create_table "funding_sources", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "id_in_data_source"
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
    t.datetime "deleted_at"
  end

  create_table "genders", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_developmental_disabilities", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_hivaids", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "has_mental_health_problems", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "letsencrypt_plugin_challenges", force: :cascade do |t|
    t.text     "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "letsencrypt_plugin_settings", force: :cascade do |t|
    t.text     "private_key"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "match_decision_reasons", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "type",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: true, null: false
  end

  add_index "match_decision_reasons", ["type"], name: "index_match_decision_reasons_on_type", using: :btree

  create_table "match_decisions", force: :cascade do |t|
    t.integer  "match_id"
    t.string   "type"
    t.string   "status"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "client_last_seen_date"
    t.datetime "criminal_hearing_date"
    t.datetime "client_move_in_date"
    t.integer  "decline_reason_id"
    t.text     "decline_reason_other_explanation"
    t.integer  "not_working_with_client_reason_id"
    t.text     "not_working_with_client_reason_other_explanation"
    t.boolean  "client_spoken_with_services_agency",               default: false
    t.boolean  "cori_release_form_submitted",                      default: false
    t.datetime "deleted_at"
    t.integer  "administrative_cancel_reason_id"
    t.string   "administrative_cancel_reason_other_explanation"
  end

  add_index "match_decisions", ["administrative_cancel_reason_id"], name: "index_match_decisions_on_administrative_cancel_reason_id", using: :btree
  add_index "match_decisions", ["decline_reason_id"], name: "index_match_decisions_on_decline_reason_id", using: :btree
  add_index "match_decisions", ["match_id"], name: "index_match_decisions_on_match_id", using: :btree
  add_index "match_decisions", ["not_working_with_client_reason_id"], name: "index_match_decisions_on_not_working_with_client_reason_id", using: :btree

  create_table "match_events", force: :cascade do |t|
    t.string   "type"
    t.integer  "match_id"
    t.integer  "notification_id"
    t.integer  "decision_id"
    t.integer  "contact_id"
    t.string   "action"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "note"
    t.datetime "deleted_at"
    t.integer  "not_working_with_client_reason_id"
    t.date     "client_last_seen_date"
    t.boolean  "admin_note",                        default: false, null: false
  end

  add_index "match_events", ["decision_id"], name: "index_match_events_on_decision_id", using: :btree
  add_index "match_events", ["match_id"], name: "index_match_events_on_match_id", using: :btree
  add_index "match_events", ["not_working_with_client_reason_id"], name: "index_match_events_on_not_working_with_client_reason_id", using: :btree
  add_index "match_events", ["notification_id"], name: "index_match_events_on_notification_id", using: :btree

  create_table "match_prioritizations", force: :cascade do |t|
    t.string   "type",                      null: false
    t.boolean  "active",     default: true, null: false
    t.integer  "weight",     default: 10,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "match_progress_updates", force: :cascade do |t|
    t.string   "type",                null: false
    t.integer  "match_id",            null: false
    t.integer  "notification_id"
    t.integer  "contact_id",          null: false
    t.integer  "decision_id"
    t.integer  "notification_number"
    t.datetime "requested_at"
    t.datetime "submitted_at"
    t.datetime "dnd_notified_at"
    t.string   "response"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.date     "client_last_seen"
  end

  add_index "match_progress_updates", ["contact_id"], name: "index_match_progress_updates_on_contact_id", using: :btree
  add_index "match_progress_updates", ["decision_id"], name: "index_match_progress_updates_on_decision_id", using: :btree
  add_index "match_progress_updates", ["match_id"], name: "index_match_progress_updates_on_match_id", using: :btree
  add_index "match_progress_updates", ["notification_id"], name: "index_match_progress_updates_on_notification_id", using: :btree
  add_index "match_progress_updates", ["type"], name: "index_match_progress_updates_on_type", using: :btree

  create_table "match_routes", force: :cascade do |t|
    t.string   "type",                                        null: false
    t.boolean  "active",                      default: true,  null: false
    t.integer  "weight",                      default: 10,    null: false
    t.boolean  "contacts_editable_by_hsa",    default: false, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "stalled_interval",            default: 7,     null: false
    t.integer  "match_prioritization_id",     default: 5,     null: false
    t.boolean  "should_cancel_other_matches", default: true,  null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "from",                       null: false
    t.string   "subject",                    null: false
    t.text     "body",                       null: false
    t.boolean  "html",       default: false, null: false
    t.datetime "seen_at"
    t.datetime "sent_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "contact_id",                 null: false
  end

  create_table "name_quality_codes", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "type"
    t.string   "code"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "client_opportunity_match_id"
    t.integer  "recipient_id"
    t.datetime "expires_at"
  end

  create_table "opportunities", force: :cascade do |t|
    t.string   "name"
    t.boolean  "available",           default: false, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "deleted_at"
    t.integer  "unit_id"
    t.float    "matchability"
    t.boolean  "available_candidate", default: true
    t.integer  "voucher_id"
    t.boolean  "success",             default: false
  end

  add_index "opportunities", ["deleted_at"], name: "index_opportunities_on_deleted_at", where: "(deleted_at IS NULL)", using: :btree
  add_index "opportunities", ["unit_id"], name: "index_opportunities_on_unit_id", using: :btree
  add_index "opportunities", ["voucher_id"], name: "index_opportunities_on_voucher_id", using: :btree

  create_table "opportunity_contacts", force: :cascade do |t|
    t.integer  "opportunity_id",                        null: false
    t.integer  "contact_id",                            null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
    t.boolean  "housing_subsidy_admin", default: false, null: false
  end

  add_index "opportunity_contacts", ["contact_id"], name: "index_opportunity_contacts_on_contact_id", using: :btree
  add_index "opportunity_contacts", ["deleted_at"], name: "index_opportunity_contacts_on_deleted_at", using: :btree
  add_index "opportunity_contacts", ["opportunity_id"], name: "index_opportunity_contacts_on_opportunity_id", using: :btree

  create_table "opportunity_properties", force: :cascade do |t|
    t.integer  "opportunity_id", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "opportunity_properties", ["opportunity_id"], name: "index_opportunity_properties_on_opportunity_id", using: :btree

  create_table "physical_disabilities", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "primary_races", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "program_contacts", force: :cascade do |t|
    t.integer  "program_id",                            null: false
    t.integer  "contact_id",                            null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
    t.boolean  "dnd_staff",             default: false, null: false
    t.boolean  "housing_subsidy_admin", default: false, null: false
    t.boolean  "client",                default: false, null: false
    t.boolean  "housing_search_worker", default: false, null: false
    t.boolean  "shelter_agency",        default: false, null: false
    t.boolean  "ssp",                   default: false, null: false
    t.boolean  "hsp",                   default: false, null: false
  end

  add_index "program_contacts", ["contact_id"], name: "index_program_contacts_on_contact_id", using: :btree
  add_index "program_contacts", ["program_id"], name: "index_program_contacts_on_program_id", using: :btree

  create_table "program_services", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "program_services", ["deleted_at"], name: "index_program_services_on_deleted_at", using: :btree
  add_index "program_services", ["program_id"], name: "index_program_services_on_program_id", using: :btree
  add_index "program_services", ["service_id"], name: "index_program_services_on_service_id", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name"
    t.string   "contract_start_date"
    t.integer  "funding_source_id"
    t.integer  "subgrantee_id"
    t.integer  "contact_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "deleted_at"
    t.boolean  "confidential",        default: false, null: false
    t.integer  "match_route_id",      default: 1
  end

  add_index "programs", ["contact_id"], name: "index_programs_on_contact_id", using: :btree
  add_index "programs", ["deleted_at"], name: "index_programs_on_deleted_at", using: :btree
  add_index "programs", ["funding_source_id"], name: "index_programs_on_funding_source_id", using: :btree
  add_index "programs", ["subgrantee_id"], name: "index_programs_on_subgrantee_id", using: :btree

  create_table "project_clients", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "ssn"
    t.date     "date_of_birth"
    t.string   "veteran_status"
    t.string   "substance_abuse_problem"
    t.date     "entry_date"
    t.date     "exit_date"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.uuid     "clientguid"
    t.string   "middle_name"
    t.integer  "ssn_quality_code"
    t.integer  "dob_quality_code"
    t.string   "primary_race"
    t.string   "secondary_race"
    t.integer  "gender"
    t.integer  "ethnicity"
    t.integer  "disabling_condition"
    t.integer  "hud_chronic_homelessness"
    t.integer  "calculated_chronic_homelessness"
    t.integer  "chronic_health_condition"
    t.integer  "physical_disability"
    t.integer  "hivaids_status"
    t.integer  "mental_health_problem"
    t.integer  "domestic_violence"
    t.integer  "discharge_type"
    t.integer  "developmental_disability"
    t.boolean  "us_citizen",                             default: false, null: false
    t.boolean  "asylee",                                 default: false, null: false
    t.boolean  "lifetime_sex_offender",                  default: false, null: false
    t.boolean  "meth_production_conviction",             default: false, null: false
    t.integer  "id_in_data_source"
    t.date     "calculated_first_homeless_night"
    t.date     "calculated_last_homeless_night"
    t.datetime "source_last_changed"
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
    t.integer  "client_id"
    t.string   "homephone"
    t.string   "cellphone"
    t.string   "workphone"
    t.string   "pager"
    t.string   "email"
    t.boolean  "dmh_eligible",                           default: false
    t.boolean  "va_eligible",                            default: false, null: false
    t.boolean  "hues_eligible",                          default: false, null: false
    t.datetime "disability_verified_on"
    t.datetime "housing_assistance_network_released_on"
    t.boolean  "sync_with_cas",                          default: false, null: false
    t.float    "income_total_monthly"
    t.datetime "income_total_monthly_last_collected"
    t.boolean  "hiv_positive",                           default: false, null: false
    t.string   "housing_release_status"
    t.boolean  "needs_update",                           default: false, null: false
    t.integer  "vispdat_score"
    t.boolean  "ineligible_immigrant",                   default: false, null: false
    t.boolean  "family_member",                          default: false, null: false
    t.boolean  "child_in_household",                     default: false, null: false
    t.integer  "days_homeless"
    t.boolean  "ha_eligible",                            default: false, null: false
    t.integer  "days_homeless_in_last_three_years"
    t.integer  "vispdat_length_homeless_in_days",        default: 0,     null: false
    t.boolean  "cspech_eligible",                        default: false
    t.string   "alternate_names"
    t.boolean  "congregate_housing",                     default: false
    t.boolean  "sober_housing",                          default: false
    t.jsonb    "enrolled_project_ids"
    t.jsonb    "active_cohort_ids"
    t.string   "client_identifier"
    t.integer  "vispdat_priority_score",                 default: 0
    t.integer  "assessment_score",                       default: 0,     null: false
  end

  add_index "project_clients", ["calculated_chronic_homelessness"], name: "index_project_clients_on_calculated_chronic_homelessness", using: :btree
  add_index "project_clients", ["client_id"], name: "index_project_clients_on_client_id", using: :btree
  add_index "project_clients", ["date_of_birth"], name: "index_project_clients_on_date_of_birth", using: :btree
  add_index "project_clients", ["source_last_changed"], name: "index_project_clients_on_source_last_changed", using: :btree

  create_table "project_programs", force: :cascade do |t|
    t.string   "id_in_data_source"
    t.string   "program_name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
  end

  create_table "reissue_requests", force: :cascade do |t|
    t.integer  "notification_id"
    t.integer  "reissued_by"
    t.datetime "reissued_at"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "request_sent_at"
  end

  add_index "reissue_requests", ["deleted_at"], name: "index_reissue_requests_on_deleted_at", using: :btree
  add_index "reissue_requests", ["notification_id"], name: "index_reissue_requests_on_notification_id", using: :btree
  add_index "reissue_requests", ["reissued_by"], name: "index_reissue_requests_on_reissued_by", using: :btree

  create_table "rejected_matches", force: :cascade do |t|
    t.integer  "client_id",      null: false
    t.integer  "opportunity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rejected_matches", ["client_id"], name: "index_rejected_matches_on_client_id", using: :btree
  add_index "rejected_matches", ["opportunity_id"], name: "index_rejected_matches_on_opportunity_id", using: :btree

  create_table "requirements", force: :cascade do |t|
    t.integer  "rule_id"
    t.integer  "requirer_id"
    t.string   "requirer_type"
    t.boolean  "positive"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "variable"
  end

  add_index "requirements", ["deleted_at"], name: "index_requirements_on_deleted_at", using: :btree
  add_index "requirements", ["requirer_type", "requirer_id"], name: "index_requirements_on_requirer_type_and_requirer_id", using: :btree
  add_index "requirements", ["rule_id"], name: "index_requirements_on_rule_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",                                                    null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "can_view_all_clients",                    default: false
    t.boolean  "can_edit_all_clients",                    default: false
    t.boolean  "can_participate_in_matches",              default: false
    t.boolean  "can_view_all_matches",                    default: false
    t.boolean  "can_see_alternate_matches",               default: false
    t.boolean  "can_edit_match_contacts",                 default: false
    t.boolean  "can_approve_matches",                     default: false
    t.boolean  "can_reject_matches",                      default: false
    t.boolean  "can_act_on_behalf_of_match_contacts",     default: false
    t.boolean  "can_view_reports",                        default: false
    t.boolean  "can_edit_roles",                          default: false
    t.boolean  "can_edit_users",                          default: false
    t.boolean  "can_view_full_ssn",                       default: false
    t.boolean  "can_view_full_dob",                       default: false
    t.boolean  "can_view_buildings",                      default: false
    t.boolean  "can_edit_buildings",                      default: false
    t.boolean  "can_view_funding_sources",                default: false
    t.boolean  "can_edit_funding_sources",                default: false
    t.boolean  "can_view_subgrantees",                    default: false
    t.boolean  "can_edit_subgrantees",                    default: false
    t.boolean  "can_view_vouchers",                       default: false
    t.boolean  "can_edit_vouchers",                       default: false
    t.boolean  "can_view_programs",                       default: false
    t.boolean  "can_edit_programs",                       default: false
    t.boolean  "can_view_opportunities",                  default: false
    t.boolean  "can_edit_opportunities",                  default: false
    t.boolean  "can_reissue_notifications",               default: false
    t.boolean  "can_view_units",                          default: false
    t.boolean  "can_edit_units",                          default: false
    t.boolean  "can_add_vacancies",                       default: false
    t.boolean  "can_view_contacts",                       default: false
    t.boolean  "can_edit_contacts",                       default: false
    t.boolean  "can_view_rule_list",                      default: false
    t.boolean  "can_edit_rule_list",                      default: false
    t.boolean  "can_view_available_services",             default: false
    t.boolean  "can_edit_available_services",             default: false
    t.boolean  "can_assign_services",                     default: false
    t.boolean  "can_assign_requirements",                 default: false
    t.boolean  "can_view_dmh_eligibility",                default: false
    t.boolean  "can_view_va_eligibility",                 default: false, null: false
    t.boolean  "can_view_hues_eligibility",               default: false, null: false
    t.boolean  "can_become_other_users",                  default: false
    t.boolean  "can_view_client_confidentiality",         default: false, null: false
    t.boolean  "can_view_hiv_positive_eligibility",       default: false
    t.boolean  "can_view_own_closed_matches",             default: false
    t.boolean  "can_edit_translations",                   default: false
    t.boolean  "can_view_vspdats",                        default: false
    t.boolean  "can_manage_config",                       default: false
    t.boolean  "can_create_overall_note",                 default: false
    t.boolean  "can_enter_deidentified_clients",          default: false
    t.boolean  "can_manage_deidentified_clients",         default: false
    t.boolean  "can_add_cohorts_to_deidentified_clients", default: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "rules", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string   "type"
    t.string   "verb"
  end

  add_index "rules", ["deleted_at"], name: "index_rules_on_deleted_at", using: :btree

  create_table "secondary_races", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_rules", force: :cascade do |t|
    t.integer  "rule_id"
    t.integer  "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "service_rules", ["deleted_at"], name: "index_service_rules_on_deleted_at", using: :btree
  add_index "service_rules", ["rule_id"], name: "index_service_rules_on_rule_id", using: :btree
  add_index "service_rules", ["service_id"], name: "index_service_rules_on_service_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "social_security_number_quality_codes", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sub_programs", force: :cascade do |t|
    t.string   "program_type"
    t.integer  "program_id"
    t.integer  "building_id"
    t.integer  "subgrantee_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "deleted_at"
    t.integer  "matched",                       default: 0
    t.integer  "in_progress",                   default: 0
    t.integer  "vacancies",                     default: 0
    t.string   "name"
    t.integer  "sub_contractor_id"
    t.integer  "hsa_id"
    t.integer  "voucher_count",                 default: 0
    t.boolean  "confidential",                  default: false, null: false
    t.text     "eligibility_requirement_notes"
  end

  add_index "sub_programs", ["building_id"], name: "index_sub_programs_on_building_id", using: :btree
  add_index "sub_programs", ["deleted_at"], name: "index_sub_programs_on_deleted_at", using: :btree
  add_index "sub_programs", ["program_id"], name: "index_sub_programs_on_program_id", using: :btree
  add_index "sub_programs", ["subgrantee_id"], name: "index_sub_programs_on_subgrantee_id", using: :btree

  create_table "subgrantee_contacts", force: :cascade do |t|
    t.integer  "subgrantee_id", null: false
    t.integer  "contact_id",    null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted_at"
  end

  add_index "subgrantee_contacts", ["contact_id"], name: "index_subgrantee_contacts_on_contact_id", using: :btree
  add_index "subgrantee_contacts", ["deleted_at"], name: "index_subgrantee_contacts_on_deleted_at", using: :btree
  add_index "subgrantee_contacts", ["subgrantee_id"], name: "index_subgrantee_contacts_on_subgrantee_id", using: :btree

  create_table "subgrantee_services", force: :cascade do |t|
    t.integer  "subgrantee_id"
    t.integer  "service_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted_at"
  end

  add_index "subgrantee_services", ["deleted_at"], name: "index_subgrantee_services_on_deleted_at", using: :btree
  add_index "subgrantee_services", ["service_id"], name: "index_subgrantee_services_on_service_id", using: :btree
  add_index "subgrantee_services", ["subgrantee_id"], name: "index_subgrantee_services_on_subgrantee_id", using: :btree

  create_table "subgrantees", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "id_in_data_source"
    t.integer  "disabled"
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
    t.datetime "deleted_at"
  end

  create_table "translation_keys", force: :cascade do |t|
    t.string   "key",        default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translation_keys", ["key"], name: "index_translation_keys_on_key", using: :btree

  create_table "translation_texts", force: :cascade do |t|
    t.text     "text"
    t.string   "locale"
    t.integer  "translation_key_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "translation_texts", ["translation_key_id"], name: "index_translation_texts_on_translation_key_id", using: :btree

  create_table "unavailable_as_candidate_fors", force: :cascade do |t|
    t.integer "client_id",        null: false
    t.string  "match_route_type", null: false
  end

  add_index "unavailable_as_candidate_fors", ["client_id"], name: "index_unavailable_as_candidate_fors_on_client_id", using: :btree
  add_index "unavailable_as_candidate_fors", ["match_route_type"], name: "index_unavailable_as_candidate_fors_on_match_route_type", using: :btree

  create_table "units", force: :cascade do |t|
    t.integer  "id_in_data_source"
    t.string   "name"
    t.boolean  "available"
    t.string   "target_population_a"
    t.string   "target_population_b"
    t.boolean  "mc_kinney_vento"
    t.integer  "chronic"
    t.integer  "veteran"
    t.integer  "adult_only"
    t.integer  "family"
    t.integer  "child_only"
    t.integer  "building_id",                null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
    t.integer  "data_source_id"
    t.string   "data_source_id_column_name"
  end

  add_index "units", ["building_id"], name: "index_units_on_building_id", using: :btree
  add_index "units", ["deleted_at"], name: "index_units_on_deleted_at", where: "(deleted_at IS NULL)", using: :btree
  add_index "units", ["id_in_data_source"], name: "index_units_on_id_in_data_source", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                              null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "encrypted_password",           default: "",          null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,           null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",              default: 0,           null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",            default: 0
    t.boolean  "receive_initial_notification", default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email_schedule",               default: "immediate", null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",         null: false
    t.integer  "item_id",           null: false
    t.string   "event",             null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "user_id"
    t.string   "session_id"
    t.string   "request_id"
    t.string   "notification_code"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "veteran_statuses", force: :cascade do |t|
    t.integer  "numeric"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vouchers", force: :cascade do |t|
    t.boolean  "available"
    t.date     "date_available"
    t.integer  "sub_program_id"
    t.integer  "unit_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
    t.integer  "user_id"
  end

  add_index "vouchers", ["deleted_at"], name: "index_vouchers_on_deleted_at", using: :btree
  add_index "vouchers", ["sub_program_id"], name: "index_vouchers_on_sub_program_id", using: :btree
  add_index "vouchers", ["unit_id"], name: "index_vouchers_on_unit_id", using: :btree

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
