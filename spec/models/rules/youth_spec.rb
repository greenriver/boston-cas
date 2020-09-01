require 'rails_helper'

RSpec.describe Rules::Youth, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :is_currently_youth }

    let!(:bob) { create :client, first_name: 'Bob', is_currently_youth: true, date_of_birth: nil }
    let!(:roy) { create :client, first_name: 'Roy', is_currently_youth: false, date_of_birth: nil }
    let!(:natural_youth) { create :client, first_name: 'Natural', is_currently_youth: false, date_of_birth: 19.years.ago.to_date }
    let!(:natural_child) { create :client, first_name: 'Child', is_currently_youth: false, date_of_birth: 17.years.ago.to_date }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'contains Bob' do
        expect(clients_that_fit.ids).to include bob.id
      end
      it 'contains Natural' do
        expect(clients_that_fit.ids).to include natural_youth.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
      it 'does not contain Child' do
        expect(clients_that_fit.ids).to_not include natural_child.id
      end
    end

    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq(2)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'does not contain Natural' do
        expect(clients_that_dont_fit.ids).to_not include natural_youth.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
      it 'contains Child' do
        expect(clients_that_dont_fit.ids).to include natural_child.id
      end
    end
  end
end