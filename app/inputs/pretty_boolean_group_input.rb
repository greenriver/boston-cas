###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class PrettyBooleanGroupInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    radio_group = template.content_tag(:div) do
      current_value = object.send(attribute_name)
      pre_label = template.content_tag(:span, '', class: 'c-checkbox__pre-label')
      if options[:pre_label].present?
        pre_label = template.content_tag(:span, options[:pre_label], class: 'c-checkbox__pre-label')
      end
      check =
        template.content_tag(:span, template.content_tag(:span, '', class: 'c-checkbox__check-icon'), class: 'c-checkbox__check-container')
      collection.each_with_index do |(label, value, attrs), index|
        name = "#{object_name}[#{attribute_name}]"
        if input_html_options[:multiple]
          checked = value.in?(current_value)
          name += '[]'
          tag_name = :check_box_tag
        else
          checked = value == current_value
          tag_name = :radio_button_tag
        end
        id = name.to_s.parameterize + '_' + value.to_s
        label_text_el = template.content_tag(:span, label, class: 'c-checkbox__label')
        checkbox_classes = ['c-checkbox', 'mb-1']
        checkbox_classes << 'c-checkbox--round' unless input_html_options[:multiple]
        template.concat(
          template.content_tag(:div, class: checkbox_classes) do
            template.send(tag_name, name, value, checked, merged_input_options.merge(id: id)) +
            template.content_tag(:label, pre_label + check + label_text_el, for: id)
          end
        )
      end
    end
    radio_group
  end

  def label

  end
end
