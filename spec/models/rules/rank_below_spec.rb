###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rules::RankBelow, type: :model do
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

    context 'when the stored value is not an integer' do
      let!(:quoted_positive) { create :requirement, rule: rule, positive: true, variable: "10'" }
      let!(:quoted_negative) { create :requirement, rule: rule, positive: false, variable: "10'" }

      it 'matches no clients for a positive requirement' do
        expect(quoted_positive.clients_that_fit(Client.all, bob_match.opportunity).ids).to be_empty
      end

      it 'matches no clients for a negative requirement' do
        expect(quoted_negative.clients_that_fit(Client.all, roy_match.opportunity).ids).to be_empty
      end
    end

    context 'when a client is ranked exactly at the threshold' do
      let!(:cy) { create :client, first_name: 'Cy', tags: {1 => 10} }

      it 'excludes the client from a positive requirement' do
        expect(positive.clients_that_fit(Client.all, bob_match.opportunity).ids).to contain_exactly(bob.id)
      end

      it 'includes the client in a negative requirement' do
        expect(negative.clients_that_fit(Client.all, roy_match.opportunity).ids).to contain_exactly(roy.id, cy.id)
      end
    end
  end
end
