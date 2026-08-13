###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: false

require_relative '../../lib/util/git'

module ApplicationHelper
  include Pagy::Frontend
  # permissions
  # See Role.rb for specifics of what permissions are available
  Role.permissions.each do |permission|
    define_method("#{permission}?") do
      current_user.try(permission)
    end
  end
  # END Permissions
  #
  def site_menu
    ::Menu::Menu.new(user: current_user, context: self).site_menu
  end

  def menu_item_active?(item)
    return false unless item.respond_to?(:path) && item.path.present?

    paths = [item.path] + Array(item.try(:alternate_paths)).compact
    paths.uniq.any? { |p| menu_request_matches_generated_path?(p) }
  rescue StandardError
    false
  end

  def yn(boolean)
    boolean ? 'Y' : 'N'
  end

  def checkmark(boolean)
    boolean ? '✓' : ''
  end

  def yes_no(bool)
    bool ? 'Yes' : 'No'
  end

  def boolean_icon(boolean)
    icon = boolean ? 'checkmark-circle' : 'times-circle-o'
    content_tag :i, '', class: "icon icon-#{icon}"
  end

  def ssn(number)
    # pad with leading 0s if we don't have enough characters
    number = number.to_s.rjust(9, '0') if number.present?
    content_tag :span, number.to_s.gsub(/(\d{3})[^\d]?(\d{2})[^\d]?(\d{4})/, '\1-\2-\3')
  end

  def masked_ssn(number)
    # pad with leading 0s if we don't have enough characters
    number = number.to_s.rjust(9, '0') if number.present?
    content_tag :span, number.to_s.gsub(/(\d{3})[^\d]?(\d{2})[^\d]?(\d{4})/, 'XXX-XX-\3')
  end

  def date_format(dob)
    dob ? l(dob, format: :default) : ''
    # dob.try(:strftime, '%m/%d/%Y')
  end

  def impersonating?
    current_user != true_user
  end

  # returns the class associated with the current sort order of a column
  def current_sort_order(columns)
    columns[sort_column] = sort_direction
    return columns
  end

  # returns a link appropriate for re-sorting a table
  def manual_sort_link(link_text, column, directions)
    direction = directions[column]
    sort_direction = direction.nil? || direction == 'asc' ? 'desc' : 'asc'
    sort = { 'sort' => column, 'direction' => sort_direction }
    params.merge!(sort)
    # FIXME: un-safe params
    link_to(link_text, params.permit!)
  end

  DATA_QUALITY_ICONS = {
    '2' => { icon: 'warning', css_class: 'text-warning', title: 'Partial/Approximate' },
    'P' => { icon: 'warning', css_class: 'text-warning', title: 'Partial/Approximate' },
    '8' => { icon: 'question', css_class: 'text-muted', title: "Client didn't know" },
    'N' => { icon: 'question', css_class: 'text-muted', title: "Client didn't know" },
    '9' => { icon: 'eye-blocked', css_class: 'text-muted', title: 'Client refused' },
    'R' => { icon: 'eye-blocked', css_class: 'text-muted', title: 'Client refused' },
  }.freeze

  def client_data_quality(model, fld)
    config = DATA_QUALITY_ICONS[model.send("#{fld}_quality").to_s]
    return unless config

    content_tag :span, class: 'cas-dq' do
      content_tag :i, '', class: "icon icon-#{config[:icon]} #{config[:css_class]}", data: { bs_toggle: :tooltip, bs_title: config[:title] }
    end
  end

  # returns a link appropriate for sorting a table as described
  def sort_as_link(link_text, column, direction = 'asc')
    sort_direction = direction.nil? || direction == 'asc' ? 'asc' : 'desc'
    sort = { 'sort' => column, 'direction' => sort_direction }
    params_copy = params.dup
    params_copy.merge!(sort)
    # FIXME: un-safe params
    link_to(link_text, params_copy.permit!, class: :jSort)
  end

  def fake_partner
    short, long = * [
      ['DND', 'Department of Neighborhood Development'],
      ['PHC', 'Public Health Commission'],
      ['Hope', 'Project Hope'],
      ['CH', 'MA Coalition for the Homeless'],
      ['DHCD', 'MA Dept. of Housing and Community Development'],
      ['Camb.', 'City of Cambridge'],
      ['VofA', 'Volunteers of America'],
      ['NECHV', 'New England Center for the Homeless Veterns'],
    ].sample
    "<abbr title=\"#{long}\">#{short}</abbr>".html_safe
  end

  def enable_responsive?
    @enable_responsive = true
  end

  def body_classes
    [].tap do |result|
      result << params[:controller]
      result << params[:action]
      result << 'not-signed-in' if current_user.blank?
    end
  end

  def container_classes
    [].tap do |result|
      result << 'non-responsive' unless enable_responsive?
    end
  end

  def current_contact
    @current_contact || current_user.try(:contact)
  end

  def ajax_modal_request?
    request.env[AjaxModalRails::Controller::HEADER].present?
  end

  def modal_size
    ''
  end

  def human_locale(locale)
    translations = {
      en: 'Text adjustments',
    }
    translations[locale.to_sym].presence || locale
  end

  def show_links_to_matches?
    false
  end

  def match_step_types
    MatchRoutes::Base.match_steps
  end

  def branch_info
    content_tag :div, class: 'navbar-text' do
      content_tag :span, Git.branch, class: 'badge badge-warning p-2'
    end
  end

  def git_revision
    Git.revision
  end

  def help_link
    @help_link ||= begin
      return nil unless help_for_path

      if help_for_path.external?
        link_to 'Help', help_for_path.external_url, class: 'o-menu__link', target: :_blank
      else
        link_to 'Help', help_path(help_for_path), class: 'o-menu__link', data: { loads_in_pjax_modal: true }
      end
    end
  end

  def help_for_path
    @help_for_path ||= Help.select(:id, :external_url, :location).for_path(
      controller_path: controller_path,
      action_name: action_name,
    )
  end

  def client_theme_stylesheet_exists?
    ApplicationHelper.client_theme_stylesheet_exists?
  end

  # Class method to check and cache the existence of a client theme stylesheet so
  # the file is only read once per deployment.
  def self.client_theme_stylesheet_exists?
    client = ENV['CLIENT'].presence
    return false unless client

    @client_theme_stylesheet_exists ||= {}
    @client_theme_stylesheet_exists.fetch(client) do
      File.exist?(Rails.root.join('app/assets/stylesheets/client_themes', "#{client}.css"))
    end
  end

  # Provides a generic mechanism to show an action menu if there is more than one item, button, if only one
  # Expects an array of objects called items in the following format
  # [{ link_to: { path: '/hud_reports/aprs/new?filter%5Bactive_roi%5D=false...'}, icon: :copy, label: 'Clone report' }, { link_to: { path: '/hud_reports/aprs/111', method: :delete }, icon: :cross, label: 'Delete' }]
  def action_menu_or_button(items:)
    return if items.empty?
    return render('/common/action_menu', items: items) if items.many?

    render('/common/action_button', item: items.sole)
  end

  private

  # current_page? treats query strings strictly; filtered match lists add extra params (sort, step, …).
  # Treat a menu link as active when the path matches and generated query keys match request params.
  def menu_request_matches_generated_path?(generated_path)
    path_part, query_part = generated_path.to_s.split('?', 2)
    return false unless request.path == path_part

    return true if query_part.blank?

    expected = Rack::Utils.parse_query(query_part)
    expected.all? { |key, val| params[key].to_s == val.to_s }
  end

  # def pretty_check_box key, label, form, attrs
  #   checked = form.object[key]
  #   value = form.object[key] ? 1 : 0
  #   id = key.to_s.parameterize
  #   content_tag :div, class: 'c-checkbox c-checkbox--round' do
  #     check_box_tag(key, value, checked, attrs.merge(id: id)) +
  #     content_tag(:label, content_tag(:span, label), for: id)
  #   end
  # end
end
