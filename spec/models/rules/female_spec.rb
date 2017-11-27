require 'rails_helper'

RSpec.describe Rules::Female, type: :model do

  let!(:male_gender) { create :male_gender}
  let!(:female_gender) { create :female_gender }
  let!(:trans_mf_gender) { create :trans_mf_gender }
  let!(:trans_fm_gender) { create :trans_fm_gender }

  let!(:female_rule) { create :rules_female }
  let!(:male_clients) { create_list :client, 2, gender_id: 1 }
  let!(:female_clients) { create_list :client, 2, gender_id: 0 }
  let!(:trans_mf_clients) { create_list :client, 2, gender_id: 2 }
  let!(:trans_fm_clients) { create_list :client, 2, gender_id: 3 }
  let!(:positive) { create :requirement, rule: female_rule, positive: true }
  let!(:negative) { create :requirement, rule: female_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }
  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches female and transgender' do
        expect( clients_that_fit.count ).to eq 6
      end
      it 'contains females' do
        expect( clients_that_fit.ids ).to include *female_clients.map(&:id)
      end
      it 'contains transgender male to female' do
        expect( clients_that_fit.ids ).to include *trans_mf_clients.map(&:id)
      end
      it 'contains transgender female to male' do
        expect( clients_that_fit.ids ).to include *trans_fm_clients.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches non-females' do
        expect( clients_that_dont_fit.count ).to eq 2
      end
      it 'contains males' do
        expect( clients_that_dont_fit.ids ).to include *male_clients.map(&:id)
      end
    end
  end
end
