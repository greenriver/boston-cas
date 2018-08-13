require 'rails_helper'

feature "Admin manages units", type: :feature do
  let(:admin) { create(:admin) }
  let!(:building) { create(:building) }

  before do
    login_as(admin)
  end

  let!(:unit) { create(:unit, building: building) }
  
  feature 'Unit CRUD' do
    scenario "viewing all building units" do
      unit2 = create(:unit, building: building)

      unit_page.goto_building

      expect(page).to have_content(unit.name)
      expect(page).to have_content(unit2.name)
      expect(current_path).to eq(building_path(building))
    end

    scenario "viewing unit details" do
      unit_page.goto_building
      unit_page.goto_unit

      expect(page).to have_content(unit.name)
      expect(current_path).to eq(edit_unit_path(unit))
    end

    scenario "successfully creating a unit" do
      unit_page.goto_building
      unit_page.create_unit(name: "My unit")

      expect(page).to have_content("My unit")
      expect(page).to have_content("Unit My unit in #{building.name} was successfully created.")
      expect(page).to_not have_content("Please review the form submission problems below")
    end

    scenario "failing to create a unique" do
      unit_page.goto_building
      unit_page.create_unit(name: " ")

      expect(page).to have_content("Please review the form submission problems below")
    end

    scenario "successfully updating a unit" do
      building2 = create(:building)

      unit_page.goto_building
      unit_page.update_unit(name: "New unit name", available: true, building_id: building2.name)

      expect(page).to have_content("New unit name")
      expect(page).to have_content("Unit New unit name was successfully updated.")

      new_unit_page = UnitPage.new(unit.reload, building2)
      new_unit_page.goto_building
      new_unit_page.goto_unit

      expect(new_unit_page.find_field("name").value).to eq("New unit name")
      expect(new_unit_page.find_field("building_id").find('option[selected]').text).to eq(building2.name)
      expect(new_unit_page.find_field("available").checked?).to eq(true)
    end

    scenario "failing to update a unit" do
      unit = create(:unit, building: building)
      unit_page.goto_building
      unit_page.update_unit(name: " ")

      expect(page).to have_content("Please review the form submission problems below")
    end
  end

  def unit_page
    @unit_page ||= UnitPage.new(unit, building)
  end
end
