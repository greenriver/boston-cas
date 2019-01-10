require 'rails_helper'

RSpec.describe Rules::Transgender, type: :model do
  describe 'clients_that_fit' do

    FEMALE = 0
    MALE = 1
    M_TO_F = 2
    F_TO_M = 3
    NO_ID = 4
    UNKNOWN = 8
    REFUSED = 9
    UNCOLLECTED = 99


    let!(:rule) { create :transgender }

    let!(:female) { create :client, gender_id: FEMALE }
    let!(:male) { create :client, gender_id: MALE }
    let!(:sue) { create :client, first_name: 'Sue', gender_id: M_TO_F  }
    let!(:roy) { create :client, first_name: 'Roy',  gender_id: F_TO_M }
    let!(:no_id) { create :client, gender_id: NO_ID }
    let!(:unknown) { create :client, gender_id: UNKNOWN }
    let!(:refused) { create :client, gender_id: REFUSED }
    let!(:uncollected) { create :client, gender_id: UNCOLLECTED }

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
      it 'matches 6' do
        expect(clients_that_dont_fit.count).to eq(6)
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