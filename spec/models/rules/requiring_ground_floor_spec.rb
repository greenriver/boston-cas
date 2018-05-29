require 'rails_helper'

RSpec.describe Rules::RequiringGroundFloor, type: :model do

  let!(:ground_floor_rule) { create :requiring_ground_floor }
  let!(:clients_requiring_ground_floor) { create_list :client, 3, requires_ground_floor: true }
  let!(:clients_not_requiring_ground_floor) { create_list :client, 2, requires_ground_floor: false }

  let!(:positive) { create :requirement, rule: ground_floor_rule, positive: true }
  let!(:negative) { create :requirement, rule: ground_floor_rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit RequiringGroundFloor' do

    context 'when positive' do
      it 'matches clients that require ground floor' do
        expect(clients_that_fit.count).to eq 3
      end
      it 'contains clients requiring ground floor' do
        expect(clients_that_fit.ids).to include *clients_requiring_ground_floor.map(&:id)
      end
      it 'does not contain clients not requiring ground floor' do
        expect(clients_that_fit.ids).to_not include *clients_not_requiring_ground_floor.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches clients that do not require ground floor' do
        expect(clients_that_dont_fit.count).to eq 2
      end
      it 'contains clients not requiring ground floor' do
        expect(clients_that_dont_fit.ids).to include *clients_not_requiring_ground_floor.map(&:id)
      end
      it 'does not contain clients requiring ground floor' do
        expect(clients_that_dont_fit.ids).to_not include *clients_requiring_ground_floor.map(&:id)
      end
    end
  end
end
