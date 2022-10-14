require 'rails_helper'

RSpec.describe Rules::Transgender, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :transgender }

    let!(:female) { create :client, female: true }
    let!(:male) { create :client, male: true }
    let!(:sue) { create :client, first_name: 'Sue', female: true, transgender: true }
    let!(:roy) { create :client, first_name: 'Roy', male: true, transgender: true }
    let!(:uncollected) { create :client }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'contains Roy' do
        expect(clients_that_fit.ids).to include roy.id
      end
      it 'contains Sue' do
        expect(clients_that_fit.ids).to include sue.id
      end
    end

    context 'when negative' do
      it 'matches 3' do
        expect(clients_that_dont_fit.count).to eq(3)
      end
      it 'does not contain Roy' do
        expect(clients_that_dont_fit.ids).to_not include roy.id
      end
      it 'does not contain Sue' do
        expect(clients_that_dont_fit.ids).to_not include sue.id
      end
    end
  end
end
