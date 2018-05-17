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
    link_to(link_text, params)
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
    params.merge!(sort)
    link_to(link_text, params)
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

  def pjax_request?
    request.env['HTTP_X_PJAX'].present?
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

end
