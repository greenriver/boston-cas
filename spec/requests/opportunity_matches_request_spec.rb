# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpportunityMatches', type: :request do
  let(:match_prioritization) { MatchPrioritization::VispdatScore.create! }
  let(:match_route) { MatchRoutes::Default.create!(match_prioritization: match_prioritization) }
  let(:program) { create(:program, match_route: match_route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:opportunity) { create(:opportunity, sub_program: sub_program) }
  let(:client) { create(:client) }
  let!(:match) { create(:client_opportunity_match, client: client, opportunity: opportunity) }

  describe 'GET /opportunities/:opportunity_id/matches' do
    context 'with a user who can view confidential information' do
      let(:user) { create(:user) }
      let(:role) { create(:role, can_view_client_confidentiality: true, can_view_all_clients: true, can_view_programs: true, can_see_all_alternate_matches: true) }

      before do
        user.roles << role
        # Create EntityViewPermission to link program to user's agency
        EntityViewPermission.create!(entity: program, user: user, agency: user.agency)
        client.update(confidential: true)
        sign_in user
        get opportunity_matches_path(opportunity)
      end

      it 'hides the client name by default' do
        expect(response.body).to include('(name hidden')
        expect(response.body).not_to include(client.name)
      end

      context 'with confidential_override' do
        it 'displays the client name' do
          get opportunity_matches_path(opportunity, params: { confidential_override: true })
          expect(response.body).to include(client.name)
        end
      end
    end

    context 'with a user who cannot view confidential information' do
      let(:user) { create(:user) }
      let(:role) { create(:role, can_view_programs: true, can_see_all_alternate_matches: true) }

      before do
        user.roles << role
        # Create EntityViewPermission to link program to user's agency
        EntityViewPermission.create!(entity: program, user: user, agency: user.agency)
        client.update(confidential: true)
        sign_in user
      end

      it 'hides the client name' do
        get opportunity_matches_path(opportunity)
        expect(response.body).to include('(name withheld')
        expect(response.body).not_to include(client.name)
      end

      context 'with confidential_override' do
        it 'still hides the client name' do
          get opportunity_matches_path(opportunity, params: { confidential_override: true })
          expect(response.body).to include('(name withheld')
          expect(response.body).not_to include(client.name)
        end
      end
    end
  end
end
