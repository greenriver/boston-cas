require 'rails_helper'

RSpec.describe Rules::IncomeLessThanEightyPercentAmi, type: :model do

  let!(:low_income_rule) { create :low_income }
  let!(:low_income_clients) { create_list :client, 2, income_total_monthly: 100 }
  let!(:no_income_clients) { create_list :client, 2, income_total_monthly: nil }
  let!(:high_income_clients) { create_list :client, 2, income_total_monthly: 999_000 }
  
  let!(:positive) { create :requirement, rule: low_income_rule, positive: true }
  let!(:negative) { create :requirement, rule: low_income_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }
  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches low and no income' do
        expect( clients_that_fit.count ).to eq 4
      end
      it 'contains low income clients' do
        expect( clients_that_fit.ids ).to include *low_income_clients.map(&:id)
      end
      it 'contains no income clients' do
        expect( clients_that_fit.ids ).to include *no_income_clients.map(&:id)
      end
      it 'does not contain high income clients' do
        expect( clients_that_fit.ids ).to_not include *high_income_clients.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches high income' do
        expect( clients_that_dont_fit.count ).to eq 2
      end
      it 'contains high income clients' do
        expect( clients_that_dont_fit.ids ).to include *high_income_clients.map(&:id)
      end
      it 'does not low income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *low_income_clients.map(&:id)
      end
      it 'does not no income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *no_income_clients.map(&:id)
      end
    end
  end
end
