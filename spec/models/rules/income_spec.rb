require 'rails_helper'

RSpec.describe Rules::Income, type: :model do

  let!(:income_rule) { create :income }
  let!(:low_income_clients) { create_list :client, 2, income_total_monthly: 100 }
  let!(:nil_income_clients) { create_list :client, 2, income_total_monthly: nil }
  let!(:zero_income_clients) { create_list :client, 2, income_total_monthly: 0 }
  
  let!(:positive) { create :requirement, rule: income_rule, positive: true }
  let!(:negative) { create :requirement, rule: income_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }
  
  describe 'clients_that_fit Income' do

    context 'when positive' do
      it 'matches low  income' do
        expect( clients_that_fit.count ).to eq 2
      end
      it 'contains low income clients' do
        expect( clients_that_fit.ids ).to include *low_income_clients.map(&:id)
      end
      it 'does not contain nil income clients' do
        expect( clients_that_fit.ids ).to_not include *nil_income_clients.map(&:id)
      end
      it 'does not contain zero income clients' do
        expect( clients_that_fit.ids ).to_not include *zero_income_clients.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches no income clients' do
        expect( clients_that_dont_fit.count ).to eq 4
      end
      it 'contains nil income clients' do
        expect( clients_that_dont_fit.ids ).to include *nil_income_clients.map(&:id)
      end
      it 'contains zero income clients' do
        expect( clients_that_dont_fit.ids ).to include *zero_income_clients.map(&:id)
      end
      it 'does not contain low income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *low_income_clients.map(&:id)
      end
    end
  end
end
