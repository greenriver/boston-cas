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
    template.content_tag :div, class: 'c-checkbox' do
      template.check_box_tag(name, value, checked, wrapper_options.merge(id: id)) +
      template.content_tag(:label, template.content_tag(:span, label_text), for: id)
    end
  end

  def label

  end
end
