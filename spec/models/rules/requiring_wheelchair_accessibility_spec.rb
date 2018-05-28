require 'rails_helper'

RSpec.describe Rules::RequiringWheelchairAccessibility, type: :model do

  let!(:wheelchair_accessibility_rule) { create :requiring_wheelchair_accessibility }
  let!(:clients_requiring_accessibility) { create_list :client, 3, requires_wheelchair_accessibility: true }
  let!(:clients_not_requiring_accessibility) { create_list :client, 2, requires_wheelchair_accessibility: false }

  let!(:positive) { create :requirement, rule: wheelchair_accessibility_rule, positive: true }
  let!(:negative) { create :requirement, rule: wheelchair_accessibility_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit RequiringWheelchairAccessibility' do

    context 'when positive' do
      it 'matches clients that require wheelchair accessibility' do
        expect(clients_that_fit.count).to eq 3
      end
      it 'contains clients requiring wheelchair accessibility' do
        expect(clients_that_fit.ids).to include *clients_requiring_accessibility.map(&:id)
      end
      it 'does not contain clients not requiring wheelchair accessibility' do
        expect(clients_that_fit.ids).to_not include *clients_not_requiring_accessibility.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches clients that do not require wheelchair accessibility' do
        expect( clients_that_dont_fit.count ).to eq 2
      end
      it 'contains clients not requiring wheelchair accessibility' do
        expect( clients_that_dont_fit.ids ).to include *clients_not_requiring_accessibility.map(&:id)
      end
      it 'does not contain clients requiring wheelchair accessibility' do
        expect( clients_that_dont_fit.ids ).to_not include *clients_requiring_accessibility.map(&:id)
      end
    end
  end
end
