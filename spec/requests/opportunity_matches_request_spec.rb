# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpportunityMatches', type: :request do
  let(:match_route) { MatchRoutes::Default.create! }
  let(:program) { create(:program, match_route: match_route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:opportunity) { create(:opportunity, sub_program: sub_program) }
  let(:client) { create(:client) }
  let!(:project_client) { create(:project_client, client: client) }
  let!(:match) { create(:client_opportunity_match, client: client, opportunity: opportunity) }

  describe 'GET /opportunities/:opportunity_id/matches' do
    context 'with a user who can view confidential information' do
      let(:user) { create(:user) }
      before do
        user.roles << create(:role, can_view_client_confidentiality: true)
        client.update(confidential: true)
        sign_in user
        get opportunity_matches_path(opportunity)
      end

      it 'displays the client name' do
        expect(response.body).to include(client.name)
      end
    end

    context 'with a user who cannot view confidential information' do
      let(:user) { create(:user) }

      before do
        client.update(confidential: true)
        sign_in user
      end

      it 'hides the client name' do
        get opportunity_matches_path(opportunity)
        expect(response.body).to include('(name withheld')
        expect(response.body).not_to include(client.name)
      end

      context 'with confidential_override' do
        it 'displays the client name' do
          get opportunity_matches_path(opportunity, params: { confidential_override: true })
          expect(response.body).to include(client.name)
        end
      end
    end
  end
end
