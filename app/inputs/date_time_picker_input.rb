###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class DateTimePickerInput < SimpleForm::Inputs::StringInput
  DATETIME_TD_OPTIONS = {
    display: {
      components: {
        clock: true,
        hours: true,
        minutes: true,
      },
      sideBySide: true,
    },
    stepping: 15,
    localization: {
      format: 'MMM d, yyyy h:mm T',
    },
  }.freeze

  def input(wrapper_options)
    set_html_options
    set_value_html_option

    template.content_tag :div, class: 'input-group date datepicker', data: { controller: 'datepicker', date_options: DATETIME_TD_OPTIONS.to_json } do
      input = super(wrapper_options)
      input + input_button
    end
  end

  def input_html_classes
    super + ['datepicker', 'form-control']
  end

  private

  def input_button
    template.content_tag :span, '', class: 'input-group-text icon-calendar', data: { td_toggle: 'datetimepicker' }
  end

  def set_html_options
    input_html_options[:type] = 'text'
  end

  def set_value_html_option
    return unless value.present?

    input_html_options[:value] ||= value.strftime(display_pattern)
  end

  def value
    object.send(attribute_name) if object.respond_to?(attribute_name)
  end

  def display_pattern
    I18n.t('datetimepicker.dformat', default: '%b %-d, %Y %-l:%M %p')
  end
end
