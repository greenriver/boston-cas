###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Builds the signed-in sidebar menu (ported from HMIS Warehouse).
class Menu::Menu
  include Rails.application.routes.url_helpers

  attr_accessor :user, :context

  def initialize(user:, context:)
    @user = user
    @context = context
  end

  def site_menu
    [].tap do |menu|
      menu << matches_section
      menu << reports_section
      if inventory_gate?
        menu << clients_section
        menu << property_section
        menu << program_section
        menu << rules_and_services_section
      end
      menu << admin_section
      menu << account_section
      menu << help_section
      menu << style_guide_section
    end.compact
  end

  private def h
    context
  end

  # Mirrors the outer condition on the inventory / HMIS section in the legacy sidebar.
  private def inventory_gate?
    h.can_view_opportunities? ||
      h.can_view_contacts? ||
      h.can_view_programs? ||
      h.can_view_assigned_programs? ||
      h.can_view_buildings? ||
      user.can_see_non_hmis_clients?
  end

  private def matches_section
    routes = MatchRoutes::Base.filterable_routes
    if routes.count > 1
      menu = Menu::Item.new(
        user: user,
        title: Translation.translate('Matches in Progress'),
        id: 'matches',
        icon: 'icon-team',
        match_pattern_terminator: '.*',
        match_pattern: '(?:^/active_matches$)|(?:^/closed_matches$)|(?:^/matches/\d+$)',
      )
      routes.each do |route|
        route_name = route.first
        menu.add_child(
          Menu::Item.new(
            user: user,
            path: active_matches_path(current_route: route_name),
            alternate_paths: [closed_matches_path(current_route: route_name)],
            title: route_name,
            visible: ->(_u) { true },
          ),
        )
      end
      menu
    else
      Menu::Item.new(
        user: user,
        path: active_matches_path,
        alternate_paths: [closed_matches_path],
        title: Translation.translate('Matches in Progress'),
        id: 'matches',
        icon: 'icon-team',
        visible: ->(_u) { true },
      )
    end
  end

  private def reports_section
    Menu::Item.new(
      user: user,
      path: reports_path,
      title: Translation.translate('Reports'),
      id: 'reports',
      icon: 'icon-flag',
      visible: ->(_user) { h.can_view_reports? },
    )
  end

  private def clients_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Clients'),
      id: 'clients',
      icon: 'icon-users',
      match_pattern_terminator: '.*',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: clients_path,
        title: Translation.translate('All Clients'),
        visible: ->(_user) { user.can_view_some_clients? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: reports_parked_clients_path,
        title: Translation.translate('Parked Clients'),
        visible: ->(_u) { Client.accessible_by_user(user).parked.any? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: deidentified_clients_path,
        title: Translation.translate('Non-HMIS Clients'),
        visible: ->(_user) { user.can_see_non_hmis_clients? && h.can_enter_deidentified_clients? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: identified_clients_path,
        title: Translation.translate('Non-HMIS Clients'),
        visible: ->(_user) { user.can_see_non_hmis_clients? && !h.can_enter_deidentified_clients? && h.can_enter_identified_clients? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: imported_clients_path,
        title: Translation.translate('Non-HMIS Clients'),
        visible: lambda { |_u|
          user.can_see_non_hmis_clients? &&
            !h.can_enter_deidentified_clients? &&
            !h.can_enter_identified_clients? &&
            h.can_manage_imported_clients?
        },
      ),
    )
    menu
  end

  private def property_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Property'),
      id: 'property',
      icon: 'icon-home3',
      match_pattern_terminator: '.*',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: opportunities_path,
        title: Translation.translate('Vacancies'),
        visible: ->(_user) { h.can_view_opportunities? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: vacancy_submissions_path,
        title: Translation.translate('Vacancy Submissions'),
        visible: ->(_user) { ! Config.active_vacancy_submission_mechanism_traditional? && h.can_view_opportunities? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: contacts_path,
        title: Translation.translate('Contacts'),
        visible: ->(_user) { h.can_view_contacts? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: buildings_path,
        title: Building.model_name.human.pluralize,
        visible: ->(_user) { h.can_view_buildings? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: neighborhoods_path,
        title: Translation.translate('Neighborhoods'),
        visible: ->(_user) { h.can_manage_neighborhoods? },
      ),
    )
    menu
  end

  private def program_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Program'),
      id: 'program',
      icon: 'icon-group',
      match_pattern_terminator: '.*',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: programs_path,
        title: Translation.translate('Programs'),
        visible: ->(_user) { h.can_view_programs? || h.can_view_assigned_programs? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: funding_sources_path,
        title: Translation.translate('Funding Sources'),
        visible: ->(_user) { h.can_view_funding_sources? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: subgrantees_path,
        title: Translation.translate('Sub-Grantees'),
        visible: ->(_user) { h.can_view_subgrantees? },
      ),
    )
    menu
  end

  private def rules_and_services_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Rules & Services'),
      id: 'rules-and-services',
      icon: 'icon-cog',
      match_pattern_terminator: '.*',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: rules_path,
        title: Translation.translate('Rules List'),
        visible: ->(_user) { h.can_view_rule_list? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: services_path,
        title: Translation.translate('Services List'),
        visible: ->(_user) { h.can_view_available_services? },
      ),
    )
    menu
  end

  private def admin_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Admin'),
      id: 'admin',
      icon: 'icon-settings_backup_restore',
      match_pattern_terminator: '.*',
      match_pattern: '(?:^/admin/)|(?:^/users/invitation)',
    )
    menu.add_child(admin_access_group)
    menu.add_child(admin_configuration_group)
    menu.add_child(admin_status_group)
    menu
  end

  private def admin_access_group
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Access'),
      id: 'admin-access',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_users_path,
        title: Translation.translate('Users'),
        visible: ->(_user) { h.can_edit_users? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_roles_path,
        title: Translation.translate('Roles'),
        visible: ->(_user) { h.can_edit_roles? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_agencies_path,
        title: Translation.translate('Agencies'),
        visible: ->(_user) { h.can_edit_users? },
      ),
    )
    menu
  end

  private def admin_configuration_group
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Configuration'),
      id: 'admin-configuration',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_configs_path,
        title: Translation.translate('Site Configuration'),
        visible: ->(_user) { h.can_manage_config? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_themes_path,
        title: Translation.translate('Theme'),
        visible: ->(_user) { h.can_manage_config? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_translation_keys_path,
        title: Translation.translate('Translations'),
        visible: ->(_user) { h.can_edit_translations? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_match_routes_path,
        title: Translation.translate('Match Routes'),
        visible: ->(_user) { h.can_manage_config? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_match_decision_reasons_path,
        title: Translation.translate('Decline & Cancel Reasons'),
        visible: ->(_user) { h.can_manage_config? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_housing_attribute_names_path,
        title: Translation.translate('Housing Attributes'),
        visible: ->(_user) { h.can_manage_config? },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: tags_path,
        title: Translation.translate('Tags'),
        visible: ->(_user) { h.can_manage_tags? },
      ),
    )
    menu
  end

  private def admin_status_group
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Status'),
      id: 'admin-status',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: admin_sessions_path,
        title: Translation.translate('Sessions'),
        visible: ->(_user) { h.can_manage_sessions? },
      ),
    )
    menu
  end

  private def account_section
    menu = Menu::Item.new(
      user: user,
      title: Translation.translate('Account'),
      id: 'account',
      icon: 'icon-user',
      match_pattern_terminator: '.*',
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: edit_account_path,
        title: Translation.translate('Edit Account'),
        visible: ->(_u) { true },
      ),
    )
    menu.add_child(
      Menu::Item.new(
        user: user,
        path: destroy_user_session_path,
        title: Translation.translate('Sign Out'),
        icon: 'icon-exit',
        visible: ->(_u) { true },
        http_method: :delete,
      ),
    )
    menu
  end

  private def help_section
    if h.can_edit_help?
      menu = Menu::Item.new(
        user: user,
        title: Translation.translate('Help'),
        id: 'help',
        icon: 'icon-question',
        match_pattern_terminator: '.*',
      )
      menu.add_child(
        Menu::Item.new(
          user: user,
          path: help_index_path,
          title: Translation.translate('Help Documents'),
          visible: ->(_u) { true },
        ),
      )
      if h.help_for_path
        menu.add_child(
          Menu::Item.new(
            user: user,
            path: edit_help_path(h.help_for_path),
            title: Translation.translate('Edit Help'),
            data: { loads_in_pjax_modal: true },
            visible: ->(_u) { true },
          ),
        )
        menu.add_child(help_link_item)
      else
        menu.add_child(
          Menu::Item.new(
            user: user,
            path: new_help_path(controller_path: h.controller_path, action_name: h.action_name),
            title: Translation.translate('Add Help Here'),
            data: { loads_in_pjax_modal: true },
            visible: ->(_u) { true },
          ),
        )
      end
      menu
    elsif h.help_for_path
      help_link_item(id: 'help', icon: 'icon-question')
    end
  end

  private def help_link_item(id: nil, icon: nil)
    path = h.help_for_path.external? ? h.help_for_path.external_url : help_path(h.help_for_path)
    Menu::Item.new(
      user: user,
      path: path,
      title: Translation.translate('Help'),
      id: id,
      icon: icon,
      target: (h.help_for_path.external? ? '_blank' : nil),
      data: (h.help_for_path.external? ? nil : { loads_in_pjax_modal: true }),
      visible: ->(_u) { true },
    )
  end

  private def style_guide_section
    return unless Rails.env.development?

    Menu::Item.new(
      user: user,
      path: style_guides_path,
      title: Translation.translate('Style Guide'),
      id: 'style-guide',
      icon: 'icon-pencil',
      visible: ->(_u) { true },
    )
  end
end
