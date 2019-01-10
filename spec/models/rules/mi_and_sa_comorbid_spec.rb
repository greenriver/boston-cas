require 'rails_helper'

RSpec.describe Rules::MiAndSaCoMorbid, type: :model do
  describe 'clients_that_fit' do

    let!(:rule) { create :mi_and_sa_co_morbid }

    let!(:bob) { create :client, first_name: 'Bob', mental_health_problem: false, substance_abuse_problem: false }
    let!(:roy) { create :client, first_name: 'Roy',  mental_health_problem: false, substance_abuse_problem: true }
    let!(:mary) { create :client, first_name: 'Mary',  mental_health_problem: true, substance_abuse_problem: false }
    let!(:sue) { create :client, first_name: 'Sue', mental_health_problem: true, substance_abuse_problem: true  }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'does not contain Bob' do
        expect(clients_that_fit.ids).to_not include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
      it 'does not contain Mary' do
        expect(clients_that_fit.ids).to_not include mary.id
      end
      it 'contains Sue' do
        expect(clients_that_fit.ids).to include sue.id
      end
    end

    context 'when negative' do
      it 'matches 3' do
        expect(clients_that_dont_fit.count).to eq(3)
      end
      it 'contains Bob' do
        expect(clients_that_dont_fit.ids).to include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
      it 'contains Mary' do
        expect(clients_that_dont_fit.ids).to include mary.id
      end
      it 'does not contain Sue' do
        expect(clients_that_dont_fit.ids).to_not include sue.id
      end
    end
  end
end