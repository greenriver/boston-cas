require 'rails_helper'

RSpec.describe Rules::Bedroom, type: :model do

  let!(:rule) { create :bedrooms_required }

  let!(:bob) {
    client = create :client, first_name: 'Bob', required_number_of_bedrooms: 4
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', required_number_of_bedrooms: 3
  }
  let!(:mary) {
    client = create :client, first_name: 'Mary', required_number_of_bedrooms: 5
  }
  let!(:positive) { create :requirement, rule: rule, positive: true, variable: 3 }
  let!(:negative) { create :requirement, rule: rule, positive: false, variable: 3 }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 1' do
        expect( clients_that_fit.count ).to eq 1
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
      it 'does not contain Mary' do
        expect( clients_that_fit.ids ).to_not include mary.id
      end
    end
    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq 2
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
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
