class UnitPage < BasePage

  attr_reader :building, :unit

  def initialize(unit, building)
    @building = building
    @unit = unit
  end

  def goto_building
    visit root_path
    within ".o-menu" do
      click_on "Buildings"
    end
    click_on building.name
  end

  def goto_unit
    goto_building
    click_on unit.name
  end

  def create_unit(attributes = {})
    goto_building
    click_on "Add Unit"
    update_fields(attributes)
    click_on "Create Unit"
  end

  def update_unit(attributes = {})
    goto_unit
    update_fields(attributes)
    click_on "Update Unit"
  end

  def click_on_update
    click_button 'Update'
  end

  def find_field(field_name)
    page.find("#unit_#{field_name}")
  end
end
