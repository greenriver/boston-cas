###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    set_html_options
    set_value_html_option

    template.content_tag :div, class: 'input-group date datepicker', data: { controller: 'datepicker' } do
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

    input_html_options[:value] ||= I18n.localize(value.to_date, format: display_pattern)
  end

  def value
    object.send(attribute_name) if object.respond_to? attribute_name
  end

  def display_pattern
    I18n.t('datepicker.dformat', default: '%b %e, %Y')
  end
end
