###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HousingAttribute, type: :model do
  let(:building) { create(:building) }

  describe 'scopes' do
    let!(:with_value_attr)    { create(:housing_attribute, :with_value, housingable: building) }
    let!(:without_value_attr) { create(:housing_attribute, :without_value, housingable: building) }

    describe '.with_value' do
      it 'returns only records where include_value is true' do
        expect(described_class.with_value).to include(with_value_attr)
        expect(described_class.with_value).not_to include(without_value_attr)
      end
    end

    describe '.without_value' do
      it 'returns only records where include_value is false' do
        expect(described_class.without_value).to include(without_value_attr)
        expect(described_class.without_value).not_to include(with_value_attr)
      end
    end
  end

  describe 'validations' do
    context 'when include_value is true' do
      subject { build(:housing_attribute, :with_value, housingable: building, value: nil) }

      it 'requires a value' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value]).to be_present
      end
    end

    context 'when include_value is false' do
      subject { build(:housing_attribute, :without_value, housingable: building, value: nil) }

      it 'does not require a value' do
        expect(subject).to be_valid
      end
    end
  end

  describe '.existing_amenities' do
    before do
      create(:housing_attribute, :without_value, housingable: building, name: 'Dishwasher')
      create(:housing_attribute, :without_value, housingable: building, name: 'Dishwasher')
      create(:housing_attribute, :without_value, housingable: building, name: 'Laundry in Unit')
      create(:housing_attribute, :with_value, housingable: building, name: 'Furniture')
    end

    it 'returns unique amenity names sorted alphabetically' do
      expect(described_class.existing_amenities).to eq(['Dishwasher', 'Laundry in Unit'])
    end

    it 'does not include with_value attribute names' do
      expect(described_class.existing_amenities).not_to include('Furniture')
    end
  end

  describe '.name_summary' do
    it 'reports a separate entry per name+type combination, never Mixed, and excludes soft-deleted rows' do
      create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
      create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '2')
      create(:housing_attribute, :without_value, housingable: building, name: 'Elevator')
      create(:housing_attribute, :with_value, housingable: building, name: 'Parking', value: 'Included')
      create(:housing_attribute, housingable: building, name: 'Parking', include_value: false, value: nil)
      deleted = create(:housing_attribute, :without_value, housingable: building, name: 'Removed')
      deleted.destroy

      summary = described_class.name_summary

      expect(summary.map { |n| [n.name, n.type] }).to contain_exactly(
        ['Bedrooms', 'Attribute'],
        ['Elevator', 'Amenity'],
        ['Parking', 'Attribute'],
        ['Parking', 'Amenity'],
      )
      bedrooms = summary.find { |n| n.name == 'Bedrooms' }
      parking_attribute = summary.find { |n| n.name == 'Parking' && n.type == 'Attribute' }
      parking_amenity = summary.find { |n| n.name == 'Parking' && n.type == 'Amenity' }
      expect(bedrooms.count).to eq(2)
      expect(parking_attribute.count).to eq(1)
      expect(parking_amenity.count).to eq(1)
    end
  end

  describe '.value_summary' do
    it 'counts each distinct value for the given name and ignores other names' do
      create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
      create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
      create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '2')
      create(:housing_attribute, :with_value, housingable: building, name: 'Bathrooms', value: '1')

      summary = described_class.value_summary('Bedrooms').index_by(&:value)

      expect(summary.keys).to contain_exactly('1', '2')
      expect(summary['1'].count).to eq(2)
      expect(summary['2'].count).to eq(1)
    end
  end

  describe '.rename' do
    around do |example|
      # PaperTrail is disabled globally for performance; enable it for this spec.
      PaperTrail.enabled = true
      example.run
      PaperTrail.enabled = false
    end

    it 'renames every matching row of the same value-type across housingable types, leaves the other value-type and other names untouched, and records a paper trail version per row' do
      unit = create(:unit, building: building)
      building_row = create(:housing_attribute, :without_value, housingable: building, name: 'Elevater')
      unit_row = create(:housing_attribute, :without_value, housingable: unit, name: 'Elevater')
      untouched_name = create(:housing_attribute, :without_value, housingable: building, name: 'Dishwasher')
      untouched_type = create(:housing_attribute, :with_value, housingable: building, name: 'Elevater', value: 'Working')

      expect { described_class.rename(old_name: 'Elevater', new_name: 'Elevator', include_value: false) }.
        to change { building_row.reload.versions.count }.by(1).
        and change { unit_row.reload.versions.count }.by(1)

      expect(building_row.reload.name).to eq('Elevator')
      expect(unit_row.reload.name).to eq('Elevator')
      expect(untouched_name.reload.name).to eq('Dishwasher')
      expect(untouched_type.reload.name).to eq('Elevater')
    end

    it 'does nothing when the new name is blank or unchanged' do
      row = create(:housing_attribute, :without_value, housingable: building, name: 'Elevator')

      expect { described_class.rename(old_name: 'Elevator', new_name: '', include_value: false) }.
        not_to(change { row.reload.name })
      expect { described_class.rename(old_name: 'Elevator', new_name: 'Elevator', include_value: false) }.
        not_to(change { row.reload.versions.count })
    end
  end

  describe '.rename_value' do
    it 'renames only rows matching both the name and the old value' do
      matching_one = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
      matching_two = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')
      other_value = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '2')
      other_name = create(:housing_attribute, :with_value, housingable: building, name: 'Bathrooms', value: '1')

      described_class.rename_value(name: 'Bedrooms', old_value: '1', new_value: 'One')

      expect(matching_one.reload.value).to eq('One')
      expect(matching_two.reload.value).to eq('One')
      expect(other_value.reload.value).to eq('2')
      expect(other_name.reload.value).to eq('1')
    end

    it 'does nothing when the old and new value are the same' do
      row = create(:housing_attribute, :with_value, housingable: building, name: 'Bedrooms', value: '1')

      expect { described_class.rename_value(name: 'Bedrooms', old_value: '1', new_value: '1') }.
        not_to(change { row.reload.versions.count })
    end
  end
end
