###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy, inverse_of: :role
  has_many :users, through: :user_roles
  validates :name, presence: true

  scope :all_except_developer, -> { where.not(name: 'developer') }

  def role_name
    name.to_s.humanize.gsub('Dnd', 'DND').gsub('Hsa', 'HSA')
  end

  def administrative?
    Role.administrative_permissions.each do |permission|
      return true if send(permission) == true
    end
    return false
  end

  def self.administrative_permissions
    [
      :can_edit_roles,
      :can_edit_users,
      :can_become_other_users,
      :can_edit_translations,
      :can_manage_config,
      :can_manage_neighborhoods,
      :can_manage_tags,
      :can_edit_help,
      :can_audit_users,
      :can_manage_sessions,
    ]
  end

  def self.permissions
    [
      :can_view_all_clients,
      :can_edit_all_clients,
      :can_edit_clients_based_on_rules,
      :can_participate_in_matches,
      :can_view_all_matches,
      :can_view_own_closed_matches,
      :can_see_alternate_matches,
      :can_see_all_alternate_matches,
      :can_edit_match_contacts,
      :can_approve_matches,
      :can_reject_matches,
      :can_act_on_behalf_of_match_contacts,
      :can_view_reports,
      :can_edit_roles,
      :can_edit_users,
      :can_view_full_ssn,
      :can_view_full_dob,
      :can_view_dmh_eligibility,
      :can_view_va_eligibility,
      :can_view_hues_eligibility,
      :can_view_hiv_positive_eligibility,
      :can_view_client_confidentiality,
      :can_view_buildings,
      :can_edit_buildings,
      :can_view_funding_sources,
      :can_edit_funding_sources,
      :can_view_subgrantees,
      :can_edit_subgrantees,
      :can_view_vouchers,
      :can_edit_vouchers,
      :can_view_programs,
      :can_view_assigned_programs,
      :can_edit_programs,
      :can_edit_assigned_programs,
      :can_edit_voucher_rules,
      :can_view_opportunities,
      :can_edit_opportunities,
      :can_reissue_notifications,
      :can_view_units,
      :can_edit_units,
      :can_add_vacancies,
      :can_view_contacts,
      :can_edit_contacts,
      :can_view_rule_list,
      :can_edit_rule_list,
      :can_view_available_services,
      :can_edit_available_services,
      :can_assign_services,
      :can_assign_requirements,
      :can_become_other_users, # This is an admin/developer only role for troubleshooting
      :can_edit_translations,
      :can_view_vspdats,
      :can_manage_config,
      :can_create_overall_note,
      :can_delete_client_notes,
      :can_enter_deidentified_clients,
      :can_manage_deidentified_clients,
      :can_export_deidentified_clients,
      :can_add_cohorts_to_deidentified_clients,
      :can_enter_identified_clients,
      :can_manage_identified_clients,
      :can_export_identified_clients,
      :can_view_all_covid_pathways,
      :can_add_cohorts_to_identified_clients,
      :can_manage_neighborhoods,
      :can_manage_tags,
      :can_manage_imported_clients,
      :can_send_notes_via_email,
      :can_upload_deidentified_clients,
      :can_delete_matches,
      :can_reopen_matches,
      :can_edit_help,
      :can_audit_users,
      :can_manage_sessions,
    ]
  end

  def self.available_roles
    Role.all_except_developer
  end

  def self.ensure_permissions_exist
    Role.permissions.each do |permission|
      ActiveRecord::Migration.add_column(:roles, permission, :boolean, default: false) unless ApplicationRecord.connection.column_exists?(:roles, permission)
    end
  end
end
