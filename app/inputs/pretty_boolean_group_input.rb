###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

class PrettyBooleanGroupInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input(wrapper_options = nil)
    radio_group = template.content_tag(:div) do
      current_value = object.send(attribute_name)
      collection.each_with_index do |(label, value, attrs), index|
        checked = value == current_value
        name = "#{object_name}[#{attribute_name}]"
        id = name.to_s.parameterize + '_' + value
        template.concat(
          template.content_tag(:div, class: 'c-checkbox c-checkbox--round') do
            template.radio_button_tag(name, value, checked, wrapper_options.merge(id: id)) +
            template.content_tag(:label, template.content_tag(:span, label), for: id)
          end
        )
      end
    end
    radio_group
  end

  def label

  end
end
