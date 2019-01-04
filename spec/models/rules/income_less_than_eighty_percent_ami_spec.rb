require 'rails_helper'

RSpec.describe Rules::IncomeLessThanEightyPercentAmi, type: :model do

  let!(:low_income_rule) { create :low_income }

  let!(:ami) { Config.get(:ami) }
  let!(:ami_partial) { (ami * 0.8) / 12 }

  let!(:boundary_client) { create :client, income_total_monthly: ami_partial }
  let!(:low_income_clients) { create_list :client, 2, income_total_monthly: ami_partial  - 1 }
  let!(:nil_income_clients) { create_list :client, 2, income_total_monthly: nil }
  let!(:zero_income_clients) { create_list :client, 2, income_total_monthly: 0 }
  let!(:high_income_clients) { create_list :client, 2, income_total_monthly: ami_partial + 1 }
  
  let!(:positive) { create :requirement, rule: low_income_rule, positive: true }
  let!(:negative) { create :requirement, rule: low_income_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }
  
  describe 'clients_that_fit IncomeLessThanEightyPercentAmi' do

    context 'when positive' do
      it 'matches boundary, low, and no income' do
        expect( clients_that_fit.count ).to eq 7
      end
      it 'contains the boundary client' do
        expect( clients_that_fit.ids ).to include boundary_client.id
      end
      it 'contains low income clients' do
        expect( clients_that_fit.ids ).to include *low_income_clients.map(&:id)
      end
      it 'contains low income clients' do
        expect( clients_that_fit.ids ).to include *low_income_clients.map(&:id)
      end
      it 'contains nil income clients' do
        expect( clients_that_fit.ids ).to include *nil_income_clients.map(&:id)
      end
      it 'contains zero income clients' do
        expect( clients_that_fit.ids ).to include *zero_income_clients.map(&:id)
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
      it 'does not contain the boundary client' do
        expect( clients_that_fit.ids ).to_not include boundary_client.id
      end
      it 'does not contain low income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *low_income_clients.map(&:id)
      end
      it 'does not contain nil income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *nil_income_clients.map(&:id)
      end
      it 'does zero contain nil income clients' do
        expect( clients_that_dont_fit.ids ).to_not include *zero_income_clients.map(&:id)
      end
    end
  end
end
