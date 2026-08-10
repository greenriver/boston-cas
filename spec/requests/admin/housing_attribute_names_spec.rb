###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::HousingAttributeNames', type: :request do
  describe 'GET index' do
    it 'redirects to root without can_manage_config' do
      role = create(:role, can_manage_config: false)
      user = create(:user)
      user.roles << role
      sign_in user

      get admin_housing_attribute_names_path

      expect(response).to redirect_to(root_path)
    end

    context 'as a user with can_manage_config' do
      let!(:admin_role) { create(:role, can_manage_config: true) }
      let!(:admin) { create(:user) }
      let!(:building) { create(:building) }
      let!(:attribute) { create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1') }

      before do
        admin.roles << admin_role
        sign_in admin
      end

      it 'links each listed name to its edit page' do
        get admin_housing_attribute_names_path

        expect(response.body).to include('Bedrooms')
        expect(response.body).to include(edit_admin_housing_attribute_name_path(attribute.id))
      end
    end
  end

  describe 'GET edit' do
    it 'redirects to root without can_manage_config' do
      role = create(:role, can_manage_config: false)
      user = create(:user)
      user.roles << role
      sign_in user
      attribute = create(:housing_attribute, :without_value, housingable: create(:building), name: 'Elevator')

      get edit_admin_housing_attribute_name_path(attribute.id)

      expect(response).to redirect_to(root_path)
    end

    context 'as a user with can_manage_config' do
      let!(:admin_role) { create(:role, can_manage_config: true) }
      let!(:admin) { create(:user) }

      before do
        admin.roles << admin_role
        sign_in admin
      end

      it 'shows every building and unit currently using the name and type, with their values, and excludes other names and the other type of the same name' do
        building = create(:building, name: 'Sunset Building')
        unit = create(:unit, name: 'Unit 2B', building: create(:building, name: 'Ocean View'))
        attribute = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
        create(:housing_attribute, :with_value, housingable: unit, name: 'Bedrooms', value: '2')
        other_building = create(:building, name: 'Not Related')
        create(:housing_attribute, :without_value, housingable: other_building, name: 'Elevator')
        amenity_building = create(:building, name: 'Amenity Building')
        create(:housing_attribute, housingable: amenity_building, name: 'Bedrooms', include_value: false, value: nil)

        get edit_admin_housing_attribute_name_path(attribute.id)

        expect(response.body).to include('Sunset Building')
        expect(response.body).to include('Unit 2B')
        expect(response.body).to include(edit_building_path(building))
        expect(response.body).to include(edit_unit_path(unit))
        expect(response.body).not_to include('Not Related')
        expect(response.body).not_to include('Amenity Building')
      end
    end
  end

  describe 'PATCH update' do
    it 'does not rename when the user lacks can_manage_config' do
      role = create(:role, can_manage_config: false)
      user = create(:user)
      user.roles << role
      sign_in user
      attribute = create(:housing_attribute, :without_value, housingable: create(:building), name: 'Elevator')

      patch admin_housing_attribute_name_path(attribute.id), params: { housing_attribute_name: { name: 'Hacked' } }

      expect(response).to redirect_to(root_path)
      expect(attribute.reload.name).to eq('Elevator')
    end

    context 'as a user with can_manage_config' do
      let!(:admin_role) { create(:role, can_manage_config: true) }
      let!(:admin) { create(:user) }

      before do
        admin.roles << admin_role
        sign_in admin
      end

      it 'renames the attribute and merges into an already-existing name of the same value-type' do
        building = create(:building)
        typo = create(:housing_attribute, :without_value, housingable: building, name: 'Elevater')
        create(:housing_attribute, :without_value, housingable: create(:unit, building: building), name: 'Elevator')

        patch admin_housing_attribute_name_path(typo.id), params: { housing_attribute_name: { name: 'Elevator' } }

        expect(response).to redirect_to(edit_admin_housing_attribute_name_path(typo.id))
        expect(typo.reload.name).to eq('Elevator')
        expect(HousingAttribute.where(name: 'Elevator', include_value: false).count).to eq(2)
      end

      it 'renaming an attribute-type name does not affect an amenity-type row with the same name, and vice versa' do
        building = create(:building)
        attribute_row = create(:housing_attribute, :with_value, housingable: building, name: 'Elevator', value: 'Freight')
        amenity_row = create(:housing_attribute, :without_value, housingable: building, name: 'Elevator')

        patch admin_housing_attribute_name_path(attribute_row.id), params: { housing_attribute_name: { name: 'Freight Elevator' } }

        expect(attribute_row.reload.name).to eq('Freight Elevator')
        expect(amenity_row.reload.name).to eq('Elevator')

        patch admin_housing_attribute_name_path(amenity_row.id), params: { housing_attribute_name: { name: 'Elevator Access' } }

        expect(amenity_row.reload.name).to eq('Elevator Access')
        expect(attribute_row.reload.name).to eq('Freight Elevator')
      end

      it 'renames a value via value_renames without changing the name' do
        building = create(:building)
        attribute = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')

        patch admin_housing_attribute_name_path(attribute.id),
              params: { housing_attribute_name: { value_renames: [{ old_value: '1', new_value: 'One' }] } }

        expect(attribute.reload.name).to eq('Bedrooms')
        expect(attribute.reload.value).to eq('One')
      end

      it 'applies value_renames against the new name when the name is changed in the same request' do
        building = create(:building)
        typo = create(:housing_attribute, :with_value, housingable: building, name: 'Bedroms', value: '1')

        patch admin_housing_attribute_name_path(typo.id),
              params: { housing_attribute_name: { name: 'Bedrooms', value_renames: [{ old_value: '1', new_value: 'One' }] } }

        expect(typo.reload.name).to eq('Bedrooms')
        expect(typo.reload.value).to eq('One')
      end
    end
  end
end
