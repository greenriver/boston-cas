###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module BaseInput
  def input(wrapper_options = nil)
    if options[:label].blank? && input_html_options[:placeholder].nil?
      input_html_options[:placeholder] = label_text
    end

    input_html_options[:autocomplete] ||= 'none'

    super # + tag.p(error_message, class: 'b-form__helper b-form__helper--error j-input-error')
  end

  def label_input(wrapper_options = nil)
    input = self.input(wrapper_options)
    if options[:label] == false
      input
    elsif options[:floating_label]
      input + label(wrapper_options) + input_hint + append
    else
      label(wrapper_options) + input + input_hint + append
    end
  end

  private def default_input_id!
    input_html_options[:id] ||= input_name.gsub(/\[/, '_').gsub(/\]/, '').presence || "si#{SecureRandom.hex}"
  end

  private def input_name
    "#{object_name}[#{attribute_name}]"
  end
end
