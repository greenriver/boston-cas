require 'rails_helper'

RSpec.describe Rules::AgeGreaterThanSixtyFive, type: :model do
  describe 'clients_that_fit' do

    let!(:rule) { create :age_greater_than_sixty_five }

    let!(:bob) { create :client, first_name: 'Bob', date_of_birth: Date.current - 64.years }
    let!(:roy) { create :client, first_name: 'Roy',  date_of_birth: Date.current - 65.years }
    let!(:mary) { create :client, first_name: 'Mary',  date_of_birth: Date.current - 66.years }
    let!(:sue) { create :client, first_name: 'Sue', date_of_birth: nil  }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'does not contain Bob (64 y.o.)' do
        expect(clients_that_fit.ids).to_not include bob.id
      end
      it 'contains Roy (Happy Birthday!)' do
        expect(clients_that_fit.ids).to include roy.id
      end
      it 'contains Mary (66 y.o.)' do
        expect(clients_that_fit.ids).to include mary.id
      end
      it 'does not contain Sue (no Birthday)' do
        expect(clients_that_fit.ids).to_not include sue.id
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
      it 'contains Bob (64 y.o.)' do
        expect(clients_that_dont_fit.ids).to include bob.id
      end
      it 'does not contain Roy (Happy Birthday!)' do
        expect(clients_that_dont_fit.ids).to_not include roy.id
      end
      it 'does not contain Mary (66 y.o)' do
        expect(clients_that_dont_fit.ids).to_not include mary.id
      end
      it 'does not contain Sue (no Birthday)' do
        expect(clients_that_dont_fit.ids).to_not include sue.id
      end
    end
  end
end