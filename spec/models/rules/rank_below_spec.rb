require 'rails_helper'

RSpec.describe Rules::RankBelow, type: :model do
  MatchRoutes::Base.ensure_all
  describe 'clients_that_fit' do
    let!(:rule) { create :rank_below }
    let!(:bob) { create :client, first_name: 'Bob', tags: {1 => 5} }
    let!(:bob_match) { create :successful_client_opportunity_match, client: bob }

    let!(:roy) { create :client, first_name: 'Roy', tags: {1 => 11} }
    let!(:roy_match) { create :unsuccessful_client_opportunity_match, client: roy }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: 10 }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: 10 }

    let(:clients_that_fit) { positive.clients_that_fit(Client.all, bob_match.opportunity) }
    let(:clients_that_dont_fit) { negative.clients_that_fit(Client.all, roy_match.opportunity) }


    before :each do
      route = MatchRoutes::ProviderOnly.first
      route.update(tag_id: 1)
      roy_match.program.update(match_route_id: route.id)
      bob_match.program.update(match_route_id: route.id)
      decision = roy.client_opportunity_matches.first.hsa_accepts_client_decision
      decision.update(decline_reason_id: hsa_decline_reason.id, status: :declined)
    end

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