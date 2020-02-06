class Select2Input < SimpleForm::Inputs::CollectionSelectInput
  include BaseInput

  def input(wrapper_options = nil)
    default_input_id!

    super + tag.script(raw "new App.Form.Select2Input('#{input_html_options[:id]}')")
  end

  def input_html_classes
    super + ['select2']
  end
end
