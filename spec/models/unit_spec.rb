require 'rails_helper'

describe Unit, type: :model do
  context "factory" do
    it "has a valid unit" do
      unit = create(:unit)

      expect(unit.valid?).to eq(true)
    end
  end

  context "association" do
    it { should have_many(:requirements) }
    it { should belong_to(:building).inverse_of(:units) }
    it { should have_many(:opportunities).inverse_of(:unit) }
    it { should have_many(:vouchers).inverse_of(:unit) }
    it { should have_one(:active_voucher).class_name("Voucher") }
    it { should have_one(:opportunity) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
  end
end
