require 'rails_helper'

RSpec.describe Rules::RequiresGroundFloor, type: :model do

  let!(:ground_floor_rule) { create :ground_floor}

  let!(:ground_floor_clients) { create_list :client, 3, requires_ground_floor: true }
  let!(:non_ground_floor_clients) { create_list :client, 2, requires_ground_floor: false }

  let!(:positive) { create :requirement, rule: ground_floor_rule, positive: true }
  let!(:negative) { create :requirement, rule: ground_floor_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit' do
    context 'when positive' do
      it 'matches clients that require ground floor' do
        expect(clients_that_fit.count).to eq(3)
        expect(clients_that_fit.ids).to include(*ground_floor_clients.map(&:id))
      end

      it 'does not match that do not require ground floor' do
        expect(clients_that_fit.ids).to_not include *non_ground_floor_clients.map(&:id)
      end
    end

    context 'when negative' do
      it 'matches the client that do not require ground floor' do
        expect(clients_that_dont_fit.ids).to_not include *ground_floor_clients.map(&:id)
      end

      it 'does not match matches the clients that require ground floor' do
        expect(clients_that_dont_fit.count).to eq(2)
        expect(clients_that_dont_fit.ids).to include(*non_ground_floor_clients.map(&:id))
      end
    end
  end
end
