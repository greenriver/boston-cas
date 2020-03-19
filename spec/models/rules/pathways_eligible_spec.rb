require 'rails_helper'

RSpec.describe Rules::PathwaysEligible, type: :model do
  MatchRoutes::Base.ensure_all
  describe 'clients_that_fit' do
    let!(:rule) { create :pathways_eligible }
    let!(:bob) { create :client, first_name: 'Bob', rrh_assessment_collected_at: '2020-03-01'.to_date }
    let!(:bob_match) { create :successful_client_opportunity_match, client: bob }

    let!(:roy) { create :client, first_name: 'Roy', rrh_assessment_collected_at: '2020-02-01'.to_date }
    let!(:hsa_decline_reason) { create :hsa_decline_reason, ineligible_in_warehouse: true }
    let!(:roy_match) { create :unsuccessful_client_opportunity_match, client: roy }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let(:clients_that_fit) { positive.clients_that_fit(Client.all, bob_match.opportunity) }
    let(:clients_that_dont_fit) { negative.clients_that_fit(Client.all, roy_match.opportunity) }

    context 'when assessment happened before decline' do
      before :each do
        roy_match.program.update(match_route_id: MatchRoutes::ProviderOnly.first.id)
        bob_match.program.update(match_route_id: MatchRoutes::ProviderOnly.first.id)
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

    context 'when assessment happened after decline' do
      before :each do
        roy_match.program.update(match_route_id: MatchRoutes::ProviderOnly.first.id)
        decision = roy.client_opportunity_matches.first.hsa_accepts_client_decision
        decision.update(decline_reason_id: hsa_decline_reason.id, status: :declined, updated_at: '2020-01-01'.to_date)
      end

      context 'when positive' do
        it 'matches 2' do
          expect(clients_that_fit.count).to eq(2)
        end
        it 'contains Bob' do
          expect(clients_that_fit.ids).to include bob.id
        end
        it 'contains Roy' do
          expect(clients_that_fit.ids).to include roy.id
        end
      end

      context 'when negative' do
        it 'matches 0' do
          expect(clients_that_dont_fit.count).to eq(0)
        end
        it 'does not contain Bob' do
          expect(clients_that_dont_fit.ids).to_not include bob.id
        end
        it 'does not contain Roy' do
          expect(clients_that_dont_fit.ids).to_not include roy.id
        end
      end
    end
  end
end