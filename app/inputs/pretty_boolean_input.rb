###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

class PrettyBooleanInput < SimpleForm::Inputs::BooleanInput
  def input(wrapper_options = nil)
    checked = object.send(attribute_name)
    name = "#{object_name}[#{attribute_name}]"
    id = name.to_s.parameterize
    value = checked ? 1 : 0
    pre_label = template.content_tag(:span, '', class: 'c-checkbox__pre-label')
    if options[:pre_label].present?
      pre_label = template.content_tag(:span, options[:pre_label], class: 'c-checkbox__pre-label')
    end
    check =
      template.content_tag(:span, template.content_tag(:span, '', class: 'c-checkbox__check-icon'), class: 'c-checkbox__check-container')
    label_text_el = template.content_tag(:span, label_text, class: 'c-checkbox__label')
    template.content_tag :div, class: 'c-checkbox' do
      template.check_box_tag(name, value, checked, wrapper_options.merge(id: id)) +
      template.content_tag(:label, pre_label + check + label_text_el, for: id)
    end
  end

  def label

  end
end
