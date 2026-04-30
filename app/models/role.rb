###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

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

  def self.permissions_with_descriptions
    {
      # Administration
      can_edit_roles: { description: 'Manage permission roles', category: 'Administration', sub_category: nil, administrative: true },
      can_edit_users: { description: 'Create and manage user accounts', category: 'Administration', sub_category: nil, administrative: true },
      can_become_other_users: { description: 'Impersonate another user for troubleshooting', category: 'Administration', sub_category: nil, administrative: true },
      can_edit_translations: { description: 'Edit UI text translations', category: 'Administration', sub_category: nil, administrative: true },
      can_manage_config: { description: 'Manage system configuration settings', category: 'Administration', sub_category: nil, administrative: true },
      can_manage_neighborhoods: { description: 'Manage neighborhood definitions', category: 'Administration', sub_category: nil, administrative: true },
      can_manage_tags: { description: 'Manage client tags', category: 'Administration', sub_category: nil, administrative: true },
      can_edit_help: { description: 'Edit in-app help content', category: 'Administration', sub_category: nil, administrative: true },
      can_audit_users: { description: 'View user audit logs', category: 'Administration', sub_category: nil, administrative: true },
      can_manage_sessions: { description: 'Manage active user sessions', category: 'Administration', sub_category: nil, administrative: true },

      # Client Access — General
      can_view_all_clients: { description: 'View all clients in the system', category: 'Client Access', sub_category: 'General', administrative: false },
      can_edit_all_clients: { description: 'Edit any client record', category: 'Client Access', sub_category: 'General', administrative: false },
      can_edit_clients_based_on_rules: { description: 'Edit clients based on rule-based access', category: 'Client Access', sub_category: 'General', administrative: false },

      # Client Access — Sensitive Data
      can_view_full_ssn: { description: 'View full Social Security Numbers', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_full_dob: { description: 'View full dates of birth', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_dmh_eligibility: { description: 'View DMH eligibility status', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_va_eligibility: { description: 'View VA eligibility status', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_hues_eligibility: { description: 'View HUES eligibility status', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_hiv_positive_eligibility: { description: 'View HIV positive eligibility status', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },
      can_view_client_confidentiality: { description: 'View confidential client information', category: 'Client Access', sub_category: 'Sensitive Data', administrative: false },

      # Client Access — Notes & Communication
      can_create_overall_note: { description: 'Create overall notes on clients', category: 'Client Access', sub_category: 'Notes & Communication', administrative: false },
      can_delete_client_notes: { description: 'Delete notes on client records', category: 'Client Access', sub_category: 'Notes & Communication', administrative: false },
      can_send_notes_via_email: { description: 'Send client notes via email', category: 'Client Access', sub_category: 'Notes & Communication', administrative: false },

      # Client Access — Assessments
      can_view_vspdats: { description: 'View VI-SPDAT assessment scores', category: 'Client Access', sub_category: 'Assessments', administrative: false },

      # Client Entry — De-identified Clients
      can_enter_deidentified_clients: { description: 'Enter and edit de-identified clients for own agency', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },
      can_manage_deidentified_clients: { description: 'Manage de-identified clients for own agency', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },
      can_manage_all_deidentified_clients: { description: 'Manage de-identified clients across all agencies', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },
      can_export_deidentified_clients: { description: 'Export de-identified client data', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },
      can_add_cohorts_to_deidentified_clients: { description: 'Add cohorts to de-identified clients', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },
      can_upload_deidentified_clients: { description: 'Upload de-identified client files', category: 'Client Entry', sub_category: 'De-identified Clients', administrative: false },

      # Client Entry — Identified Clients
      can_enter_identified_clients: { description: 'Enter and edit identified clients for own agency', category: 'Client Entry', sub_category: 'Identified Clients', administrative: false },
      can_manage_identified_clients: { description: 'Manage identified clients for own agency', category: 'Client Entry', sub_category: 'Identified Clients', administrative: false },
      can_manage_all_identified_clients: { description: 'Manage identified clients across all agencies', category: 'Client Entry', sub_category: 'Identified Clients', administrative: false },
      can_export_identified_clients: { description: 'Export identified client data', category: 'Client Entry', sub_category: 'Identified Clients', administrative: false },
      can_add_cohorts_to_identified_clients: { description: 'Add cohorts to identified clients', category: 'Client Entry', sub_category: 'Identified Clients', administrative: false },

      # Client Entry — Imported Clients
      can_manage_imported_clients: { description: 'Manage clients imported from external sources', category: 'Client Entry', sub_category: 'Imported Clients', administrative: false },

      # Matches — Participation
      can_participate_in_matches: { description: 'Participate in the match process as a contact', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_view_all_matches: { description: 'View all matches in the system', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_view_own_closed_matches: { description: 'View own closed matches', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_see_alternate_matches: { description: 'View alternate match candidates for own matches', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_see_all_alternate_matches: { description: 'View all alternate match candidates', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_edit_match_contacts: { description: 'Edit contacts on a match', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_approve_matches: { description: 'Approve matches at final step', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_reject_matches: { description: 'See and use the cancel match functionality', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_act_on_behalf_of_match_contacts: { description: 'Act on behalf of another match contact', category: 'Matches', sub_category: 'Participation', administrative: false },
      can_reissue_notifications: { description: 'Resend match notifications', category: 'Matches', sub_category: 'Participation', administrative: false },

      # Matches — Match Management
      can_delete_matches: { description: 'Permanently delete matches', category: 'Matches', sub_category: 'Match Management', administrative: false },
      can_reopen_matches: { description: 'Reopen closed matches', category: 'Matches', sub_category: 'Match Management', administrative: false },
      can_activate_matches: { description: 'Activate proposed matches', category: 'Matches', sub_category: 'Match Management', administrative: false },

      # Housing Inventory — Buildings & Units
      can_view_buildings: { description: 'View building records', category: 'Housing Inventory', sub_category: 'Buildings & Units', administrative: false },
      can_edit_buildings: { description: 'Create and edit building records', category: 'Housing Inventory', sub_category: 'Buildings & Units', administrative: false },
      can_view_units: { description: 'View unit records', category: 'Housing Inventory', sub_category: 'Buildings & Units', administrative: false },
      can_edit_units: { description: 'Create and edit unit records', category: 'Housing Inventory', sub_category: 'Buildings & Units', administrative: false },
      can_add_vacancies: { description: 'Create vacancies, which result in vouchers ready to match', category: 'Housing Inventory', sub_category: 'Buildings & Units', administrative: false },

      # Housing Inventory — Programs & Vouchers
      can_view_programs: { description: 'View all programs', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_view_assigned_programs: { description: 'View programs assigned to own agency', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_edit_programs: { description: 'Create and edit programs', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_edit_assigned_programs: { description: 'Edit programs assigned to own agency', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_view_vouchers: { description: 'View voucher and the voucher tab within a program', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_edit_vouchers: { description: 'Create and edit voucher within programs', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },
      can_edit_voucher_rules: { description: 'Edit voucher eligibility rules', category: 'Housing Inventory', sub_category: 'Programs & Vouchers', administrative: false },

      # Housing Inventory — Opportunities
      can_view_opportunities: { description: 'View housing opportunities', category: 'Housing Inventory', sub_category: 'Opportunities', administrative: false },
      can_edit_opportunities: { description: 'Create and edit housing opportunities', category: 'Housing Inventory', sub_category: 'Opportunities', administrative: false },

      # Housing Inventory — Funding & Subgrantees
      can_view_funding_sources: { description: 'View funding source records', category: 'Housing Inventory', sub_category: 'Funding & Subgrantees', administrative: false },
      can_edit_funding_sources: { description: 'Create and edit funding sources', category: 'Housing Inventory', sub_category: 'Funding & Subgrantees', administrative: false },
      can_view_subgrantees: { description: 'View subgrantee organizations', category: 'Housing Inventory', sub_category: 'Funding & Subgrantees', administrative: false },
      can_edit_subgrantees: { description: 'Create and edit subgrantee organizations', category: 'Housing Inventory', sub_category: 'Funding & Subgrantees', administrative: false },

      # Contacts
      can_view_contacts: { description: 'View contact records', category: 'Contacts', sub_category: nil, administrative: false },
      can_edit_contacts: { description: 'Create and edit contact records', category: 'Contacts', sub_category: nil, administrative: false },

      # Rules & Services — Rules
      can_view_rule_list: { description: 'View eligibility rules', category: 'Rules & Services', sub_category: 'Rules', administrative: false },
      can_edit_rule_list: { description: 'Create and edit eligibility rules', category: 'Rules & Services', sub_category: 'Rules', administrative: false },
      can_assign_requirements: { description: 'Assign requirements to programs', category: 'Rules & Services', sub_category: 'Rules', administrative: false },

      # Rules & Services — Services
      can_view_available_services: { description: 'View available services', category: 'Rules & Services', sub_category: 'Services', administrative: false },
      can_edit_available_services: { description: 'Create and edit available services', category: 'Rules & Services', sub_category: 'Services', administrative: false },
      can_assign_services: { description: 'Assign services to clients', category: 'Rules & Services', sub_category: 'Services', administrative: false },

      # Reports
      can_view_reports: { description: 'View system reports', category: 'Reports', sub_category: nil, administrative: false },
      can_view_all_covid_pathways: { description: 'View COVID pathway data', category: 'Reports', sub_category: nil, administrative: false },
    }.freeze
  end

  def self.permissions_by_group
    @permissions_by_group ||= permissions_with_descriptions.each_with_object({}) do |(perm, meta), groups|
      cat = meta[:category]
      sub = meta[:sub_category]
      groups[cat] ||= {}
      groups[cat][sub] ||= []
      groups[cat][sub] << meta.merge(name: perm)
    end.freeze
  end

  def self.permission_categories
    @permission_categories ||= permissions_with_descriptions.values.map { |m| m[:category] }.uniq.freeze
  end

  def color_index
    (name.bytes.sum % 75) + 1
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
      :can_enter_deidentified_clients, # Allows entering/editing de-identified clients for the user's own agency. (Required for access, even if you are just "managing")
      :can_manage_deidentified_clients, # allows managing de-identified clients for the user's own agency.
      :can_manage_all_deidentified_clients, # Administrative permission: Allows managing de-identified clients across all agencies.
      :can_export_deidentified_clients,
      :can_add_cohorts_to_deidentified_clients,
      :can_enter_identified_clients, # Allows entering/editing identified clients for the user's own agency. (Required for access, even if you are just "managing")
      :can_manage_identified_clients, # allows managing identified clients for the user's own agency.
      :can_manage_all_identified_clients, # Administrative permission: Allows managing identified clients across all agencies.
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
      :can_activate_matches,
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
