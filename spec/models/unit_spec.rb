require 'rails_helper'

describe Unit, type: :model do
  context "factory" do
    it "has a valid unit" do
      unit = create(:unit)

      expect(unit.valid?).to eq(true)
    end
  end
end
