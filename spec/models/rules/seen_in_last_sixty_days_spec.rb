require 'rails_helper'

RSpec.describe Rules::SeenInLastSixtyDays, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :seen_in_last_sixty_days }

    let!(:bob) { create :client, first_name: 'Bob', calculated_last_homeless_night: 59.days.ago.to_date }
    let!(:roy) { create :client, first_name: 'Roy', calculated_last_homeless_night: 61.days.ago.to_date }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'contains Bob' do
        expect(clients_that_fit.ids).to include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
    end
  end
end