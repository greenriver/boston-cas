require 'rails_helper'

feature "Admin manages units", type: :feature do

  let(:admin) { create(:admin) }
  let!(:building) { create(:building) }

  before do
    login_as(admin)
  end

  feature 'Unit CRUD' do
    scenario "viewing all building units" do
      unit1 = create(:unit, building: building)
      unit2 = create(:unit, building: building)

      goto_building(building)

      expect(page).to have_content(unit1.name)
      expect(page).to have_content(unit2.name)
      expect(current_path).to eq(building_path(building))
    end

    scenario "viewing unit details" do
      unit = create(:unit, building: building)
      goto_unit(unit, building)

      expect(page).to have_content(unit.name)
      expect(current_path).to eq(edit_unit_path(unit))
    end

    scenario "successfully creating a unit" do
      goto_building(building)
      create_unit(name: "My unit")

      expect(page).to have_content("My unit")
      expect(page).to have_content("Unit My unit in #{building.name} was successfully created.")
      expect(page).to_not have_content("Please review the form submission problems below")
    end

    scenario "failing to create a unique" do
      goto_building(building)
      create_unit(name: " ")

      expect(page).to have_content("Please review the form submission problems below")
    end

    scenario "successfully updating a unit" do
      building2 = create(:building)
      unit = create(:unit, building: building)
      goto_building(building)
      update_unit(unit, building, name: "New unit name", available: true, building_id: building2.name)

      expect(page).to have_content("New unit name")
      expect(page).to have_content("Unit New unit name was successfully updated.")

      goto_building(building2)
      goto_unit(unit.reload, building2)

      expect(find_field("unit[name]").value).to eq("New unit name")
      expect(find_field("unit[building_id]").find('option[selected]').text).to eq(building2.name)
      expect(find_field("unit[available]").checked?).to eq(true)
    end

    scenario "failing to update a unit" do
      unit = create(:unit, building: building)
      goto_building(building)
      update_unit(unit, building, name: " ")

      expect(page).to have_content("Please review the form submission problems below")
    end
  end
  
  def goto_building(building)
    visit root_path
    within ".o-menu" do
      click_on "Buildings"
    end
    click_on building.name
  end

  def goto_unit(unit, building)
    goto_building(building)
    click_on unit.name
  end

  def create_unit(attributes={})
    goto_building(building)
    click_on "Add Unit"
    update_fields(attributes)
    click_on "Create Unit"
  end

  def update_unit(unit, building, attributes={})
    goto_unit(unit, building)
    update_fields(attributes)
    click_on "Update Unit"
  end

  def page!
    save_and_open_page
  end

  def update_fields(attributes)
    return unless attributes.present?
    attributes.each { |name, value| update_field(name, value) unless value.nil? }
  end

  def update_field(name, value)
    field = page.find("#unit_#{name}")

    if field.tag_name == "select"
      field.find(:option, value).select_option
    else

      if !!value == value
        value ? check("unit_#{name}") : uncheck("unit_#{name}")
      else
        field.set(value)
      end
    end
  end
end
