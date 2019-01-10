require 'rails_helper'

RSpec.describe Rules::SeenInLastNinetyDays, type: :model do

  let!(:last_seen_rule) { create :last_seen_90 }

  let!(:bob) { 
    client = create :client, first_name: 'Bob', calculated_last_homeless_night: 6.months.ago
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', calculated_last_homeless_night: 15.days.ago
  }
  let!(:sue) {
    client = create :client, first_name: 'Sue', calculated_last_homeless_night: 90.days.ago
  }
  let!(:positive) { create :requirement, rule: last_seen_rule, positive: true }
  let!(:negative) { create :requirement, rule: last_seen_rule, positive: false }
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
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
      it 'contains Sue' do
        expect( clients_that_fit.ids ).to include sue.id
      end
    end
    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq 1
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
      it 'does not contain Sue' do
        expect( clients_that_dont_fit.ids ).to_not include sue.id
      end
    end
  end
end
