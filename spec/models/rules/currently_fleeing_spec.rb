require 'rails_helper'

RSpec.describe Rules::CurrentlyFleeing, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :currently_fleeing }

    let!(:bob) { create :client, first_name: 'Bob', currently_fleeing: true, dv_date: 3.months.ago.to_date }
    let!(:roy) { create :client, first_name: 'Roy', currently_fleeing: false }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'contains Bob' do
        expect(clients_that_fit.ids).to include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
      it 'does not match Bob when the date is too old or missing' do
        bob.update(dv_date: bob.dv_date - 1.days)
        expect(clients_that_fit.count).to eq(0)
        bob.update(dv_date: nil)
        expect(clients_that_fit.count).to eq(0)
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
    end
  end
end
