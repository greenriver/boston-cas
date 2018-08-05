require 'rails_helper'

describe Unit, type: :model do
  context "factory" do
    it "has a valid unit" do
      unit = create(:unit)

      expect(unit.valid?).to eq(true)
    end
  end

  context "validations" do
    it { should validate_inclusion_of(:target_population).in_array(Unit.available_target_population).allow_blank }
  end

  context ".available_target_population" do
    it "includes the correct target population" do
      expect(Unit.available_target_population).to eq(%w[youth family individual])
    end
  end
end
