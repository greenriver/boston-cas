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
end
