###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class PrettyBooleanInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    checked = object.send(attribute_name)
    name = "#{object_name}[#{attribute_name}]"
    id = name.to_s.parameterize
    pre_label = template.content_tag(:span, '', class: 'c-checkbox__pre-label')
    pre_label = template.content_tag(:span, options[:pre_label], class: 'c-checkbox__pre-label') if options[:pre_label].present?

    check =
      template.content_tag(:span, template.content_tag(:span, '', class: 'c-checkbox__check-icon'), class: 'c-checkbox__check-container')
    label_text_el = template.content_tag(:span, label_text)
    # hint_text = template.content_tag(:span, options[:hint], class: 'c-checkbox__hint')
    label = template.content_tag(:span, label_text_el, class: 'c-checkbox__label')
    template.content_tag :div, class: 'c-checkbox' do
      build_hidden_field_for_checkbox +
      template.check_box_tag(name, 1, checked, merged_input_options.merge(id: id)) +
      template.content_tag(:label, pre_label + check + label, for: id)
    end
  end

  def label
  end
end
