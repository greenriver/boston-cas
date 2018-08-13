class BasePage
  include Rails.application.routes.url_helpers
  include RSpec::Matchers
  include Capybara::DSL
  include AuthenticationSupport::Feature
  include Menus::Menu

  delegate :create, :build, to: FactoryGirl

  attr_accessor :user

  def find_checkbox(id)
    page.find("input[type='checkbox'][id='#{id}']")
  end

  def update_fields(attributes)
    return unless attributes.present?
    attributes.each { |name, value| update_field(name, value) unless value.nil? }
  end

  def update_field(name, value)
    field = find_field(name)

    if field.tag_name == "select"
      field.find(:option, value).select_option
    else
      field.set(value)
    end
  end
end
