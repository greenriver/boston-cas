###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match route links on the opportunity matches page', type: :request do
  let!(:contact) { create :macbeth }
  let!(:user) { create :user, contact: contact }
  let!(:prioritization_scheme) { create :priority_days_homeless }
  let!(:route) do
    route = MatchRoutes::Default.first
    route.update(match_prioritization: prioritization_scheme, should_prevent_multiple_matches_per_client: false)
    route
  end
  let!(:match) { create :client_opportunity_match, active: false, match_route: route }
  let!(:project_client) { create :project_client, client_id: match.client.id }
  let(:opportunity) { match.opportunity }
  let(:client) { match.client }
  let!(:other_match) { create :client_opportunity_match, client: client, match_route: route }
  let(:second_route) { MatchRoutes::ProviderOnly.first }
  let!(:second_route_match) { create :client_opportunity_match, client: client, match_route: second_route }
  let(:route_text) { "#{route.title} (1)" }
  let(:second_route_text) { "#{second_route.title} (1)" }
  let(:client_matches_href) { %(href="#{client_matches_path(client)}") }
  let!(:role) do
    create :role,
           can_see_all_alternate_matches: true,
           can_edit_assigned_programs: true,
           can_view_assigned_programs: true,
           can_activate_matches: true,
           can_view_all_matches: true
  end

  before do
    sign_in user
    EntityViewPermission.create(entity: match.program, agency: user.agency, editable: true)
    user.roles << role
  end

  context 'when the user cannot view the client' do
    it 'shows every route as plain text without a link to the client matches page' do
      get opportunity_matches_path(opportunity)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(route_text)
      expect(response.body).to include(second_route_text)
      expect(response.body).not_to include(client_matches_href)
    end
  end

  context 'when the user can view the client' do
    before { role.update!(can_view_all_clients: true) }

    it 'links every route to the client matches page' do
      get opportunity_matches_path(opportunity)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(route_text)
      expect(response.body).to include(second_route_text)
      expect(response.body.scan(client_matches_href).size).to eq(2)
    end

    context 'without permission to view all matches' do
      before { role.update!(can_view_all_matches: false) }

      it 'shows every route as plain text without a link to the client matches page' do
        get opportunity_matches_path(opportunity)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(route_text)
        expect(response.body).to include(second_route_text)
        expect(response.body).not_to include(client_matches_href)
      end
    end
  end
end
