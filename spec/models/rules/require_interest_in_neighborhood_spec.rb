require 'rails_helper'

RSpec.describe Rules::RequireInterestInNeighborhood, type: :model do
  describe 'clients_that_fit' do

    let!(:cambridge) { create :neighborhood_cambridge }
    let!(:beacon_hill) { create :neighborhood_beacon_hill }

    let!(:rule) { create :require_interest_in_neighborhood }

    let!(:bob) { create :client, first_name: 'Bob', neighborhood_interests: [ cambridge.id ] }
    let!(:roy) { create :client, first_name: 'Roy', neighborhood_interests: [ beacon_hill.id ] }
    let!(:mary) { create :client, first_name: 'Mary', neighborhood_interests: [ cambridge.id, beacon_hill.id ] }
    let!(:sue) { create :client, first_name: 'Sue', neighborhood_interests: [ ] }
    let!(:zelda) { create :client, first_name: 'Zelda', neighborhood_interests: [ "#{cambridge.id}" ] }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 4' do
        expect(clients_that_fit.count).to eq(4)
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
    end

  end
end
