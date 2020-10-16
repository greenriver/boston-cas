###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module ApplicationHelper
  # permissions
  # See Role.rb for specifics of what permissions are available
  Role.permissions.each do |permission|
    define_method("#{permission}?") do
      current_user.try(permission)
    end
  end
  # END Permissions
  #
  def yn(boolean)
    boolean ? 'Y': 'N'
  end

  def checkmark(boolean)
    boolean ? '✓': ''
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
    #dob.try(:strftime, '%m/%d/%Y')
  end

  def impersonating?
    current_user != true_user
  end

  # returns the class associated with the current sort order of a column
  def current_sort_order(columns)
    columns[sort_column] = sort_direction
    return columns
  end

  #returns a link appropriate for re-sorting a table
  def manual_sort_link(link_text, column, directions)
    direction = directions[column]
    sort_direction = (direction.nil? || direction == 'asc') ? 'desc' : 'asc'
    sort = {'sort' => column, 'direction' => sort_direction}
    params.merge!(sort)
    # FIXME: un-safe params
    link_to(link_text, params.permit!)
  end

  def client_data_quality(model, fld)
    content_tag :span, class: 'cas-dq' do
      case model.send("#{fld}_quality")
      #when 'F'; icon('check-circle', class: 'text-success', data: {toggle: :tooltip}, title: 'Full')
      when 'P'; icon('exclamation-triangle', class: 'text-warning', data: {toggle: :tooltip}, title: 'Partial/Approximate')
      when 'N'; icon('question-circle', class: 'text-muted', data: {toggle: :tooltip}, title: 'Client didn\'t know')
      when 'R'; icon('eye-slash', class: 'text-muted', data: {toggle: :tooltip}, title: 'Client refused')
      end
    end
  end

  #returns a link appropriate for sorting a table as described
  def sort_as_link(link_text, column, direction='asc')
    sort_direction = (direction.nil? || direction == 'asc') ? 'asc' : 'desc'
    sort = {'sort' => column, 'direction' => sort_direction}
    params_copy = params.dup
    params_copy.merge!(sort)
    # FIXME: un-safe params
    link_to(link_text, params_copy.permit!, class: :jSort)
  end

  def fake_partner
    short, long = * [
      ['DND','Department of Neighborhood Development'],
      ['PHC','Public Health Commission'],
      ['Hope','Project Hope'],
      ['CH','MA Coalition for the Homeless'],
      ['DHCD','MA Dept. of Housing and Community Development'],
      ['Camb.','City of Cambridge'],
      ['VofA','Volunteers of America'],
      ['NECHV','New England Center for the Homeless Veterns']
    ].sample
    "<abbr title=\"#{long}\">#{short}</abbr>".html_safe
  end

  def enable_responsive?
    @enable_responsive  = true
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

  def human_locale(locale)
    translations = {
      en: 'Text adjustments'
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
    branch_name = `git rev-parse --abbrev-ref HEAD`
    content_tag :div, :class => "navbar-text" do
      content_tag :span, branch_name, :class => "badge badge-warning p-2"
    end
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
