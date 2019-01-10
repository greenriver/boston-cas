require 'rails_helper'

RSpec.describe Rules::Occupancy, type: :model do

  let!(:rule) { create :minimum_occupancy }

  let!(:bob) {
    client = create :client, first_name: 'Bob', required_minimum_occupancy: 4
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', required_minimum_occupancy: 2
  }
  let!(:mary) {
    client = create :client, first_name: 'Mary', required_minimum_occupancy: 7
  }
  let!(:positive) { create :requirement, rule: rule, positive: true, variable: 4 }
  let!(:negative) { create :requirement, rule: rule, positive: false, variable: 4 }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 2' do
        expect( clients_that_fit.count ).to eq 2
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'contains Bob' do
        expect( clients_that_fit.ids ).to include bob.id
      end
      it 'does not contain Mary' do
        expect( clients_that_fit.ids ).to_not include mary.id
      end
    end
    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq 1
      end
      it 'does not contains Bob' do
        expect( clients_that_dont_fit.ids ).to_not include bob.id
      end
      it 'contains Mary' do
        expect( clients_that_dont_fit.ids ).to include mary.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
    end
  end
end
