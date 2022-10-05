require 'rails_helper'

RSpec.describe Rules::Female, type: :model do
  let!(:female_rule) { create :rules_female }
  let!(:male_clients) { create_list :client, 2, male: true }
  let!(:female_clients) { create_list :client, 2, female: true }
  let!(:trans_mf_clients) { create_list :client, 2, female: true, transgender: true }
  let!(:trans_fm_clients) { create_list :client, 2, male: true, transgender: true }
  let!(:positive) { create :requirement, rule: female_rule, positive: true }
  let!(:negative) { create :requirement, rule: female_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }


  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches female and TMF' do
        expect( clients_that_fit.count ).to eq 4
      end
      it 'contains females' do
        expect( clients_that_fit.ids ).to include *female_clients.map(&:id)
      end
      it 'contains TMF' do
        expect( clients_that_fit.ids ).to include *trans_mf_clients.map(&:id)
      end
      it 'does not contain TFM' do
        expect( clients_that_fit.ids ).to_not include *trans_fm_clients.map(&:id)
      end
      it 'does not contain males' do
        expect( clients_that_fit.ids ).to_not include *male_clients.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches non-females' do
        expect( clients_that_dont_fit.count ).to eq 4
      end
      it 'contains males' do
        expect( clients_that_dont_fit.ids ).to include *male_clients.map(&:id)
      end
      it 'contains TFM' do
        expect( clients_that_dont_fit.ids ).to include *trans_fm_clients.map(&:id)
      end
      it 'does not contain females' do
        expect( clients_that_dont_fit.ids ).to_not include *female_clients.map(&:id)
      end
      it 'does not contain TMF' do
        expect( clients_that_dont_fit.ids ).to_not include *trans_mf_clients.map(&:id)
      end
    end
  end
end
