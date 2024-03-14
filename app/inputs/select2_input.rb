###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Select2Input < SimpleForm::Inputs::CollectionSelectInput
  include BaseInput

  def input(wrapper_options = nil)
    default_input_id!
    merged_input_options = merge_wrapper_options(input_html_options.merge(style: 'width: 100%;'), wrapper_options)
    super(merged_input_options) + tag.script(raw("new App.Form.Select2Input('#{input_html_options[:id]}')"))
  end

  def input_html_classes
    super + ['select2']
  end
end
