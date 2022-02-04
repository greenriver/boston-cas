###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class PrettyCheckboxesGroupInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    group = template.content_tag(:div) do
      current_value = object.send(attribute_name)
      name = "#{object_name}[#{attribute_name}][]"
      template.concat(
        template.content_tag(:input, nil, type: :hidden, name: name, value: '')
      )
      check =
        template.content_tag(:span, template.content_tag(:span, '', class: 'c-checkbox__check-icon'), class: 'c-checkbox__check-container')

      collection.each do |label, value, _|
        checked = current_value && value.in?(current_value)
        id = name.to_s.parameterize + '_' + value.to_s
        label_text_el = template.content_tag(:span, label, class: 'c-checkbox__label')
        checkbox_classes = ['c-checkbox', 'mb-1']
        template.concat(
          template.content_tag(:div, class: checkbox_classes) do
            template.send(:check_box_tag, name, value, checked, merged_input_options.merge(id: id)) +
            template.content_tag(:label, check + label_text_el, for: id)
          end,
        )
      end
    end
    group
  end
end
