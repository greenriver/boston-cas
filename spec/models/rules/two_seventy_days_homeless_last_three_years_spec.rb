require 'rails_helper'

RSpec.describe Rules::TwoSeventyDaysHomelessLastThreeYears, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :two_seventy_days_homeless_last_three_years }

    let!(:bob) { create :client, first_name: 'Bob', days_homeless_in_last_three_years: 269 }
    let!(:roy) { create :client, first_name: 'Roy', days_homeless_in_last_three_years: 270 }
    let!(:sue) { create :client, first_name: 'Sue', days_homeless_in_last_three_years: 271 }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'does not contain Bob' do
        expect(clients_that_fit.ids).to_not include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_fit.ids).to include roy.id
      end
      it 'contains Sue' do
        expect(clients_that_fit.ids).to include sue.id
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
      it 'contains Bob' do
        expect(clients_that_dont_fit.ids).to include bob.id
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