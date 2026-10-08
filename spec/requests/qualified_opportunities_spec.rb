###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Qualified opportunities', type: :request do
  let!(:active_route) { MatchRoutes::Default.first.tap { |r| r.update!(active: true) } }
  let!(:inactive_route) { MatchRoutes::Four.first.tap { |r| r.update!(active: false) } }
  let!(:client) { create :client }
  let!(:active_route_opportunity) do
    create :opportunity, voucher: create(:voucher, sub_program: create(:sub_program, program: create(:program, match_route: active_route)))
  end
  let!(:inactive_route_opportunity) do
    create :opportunity, voucher: create(:voucher, sub_program: create(:sub_program, program: create(:program, match_route: inactive_route)))
  end
  let(:user) { create :user }

  def opportunity_link(opportunity)
    %(href="#{opportunity_matches_path(opportunity)}")
  end

  def parsed_table
    Nokogiri::HTML(response.body).at_css('table')
  end

  before(:each) { sign_in user }

  context 'when the user can edit all clients' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true, can_edit_all_clients: true) }

    describe 'GET index' do
      it 'lists opportunities on active routes and omits those on inactive routes' do
        get client_qualified_opportunities_path(client_id: client.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(opportunity_link(active_route_opportunity))
        expect(response.body).not_to include(opportunity_link(inactive_route_opportunity))
      end

      it 'omits the match route column when only one route is active' do
        get client_qualified_opportunities_path(client_id: client.id)

        headers = parsed_table.css('thead th').map(&:text)
        cells = parsed_table.css('tbody tr').first.css('td, th')
        expect(headers).not_to include('Match Route')
        expect(cells.size).to eq(headers.size)
      end

      context 'when more than one route is active' do
        before(:each) { MatchRoutes::ProviderOnly.first.update!(active: true) }

        it 'shows the match route title under the match route column' do
          get client_qualified_opportunities_path(client_id: client.id)

          headers = parsed_table.css('thead th').map(&:text)
          cells = parsed_table.css('tbody tr').first.css('td, th').map(&:text)
          expect(cells.size).to eq(headers.size)
          expect(cells[headers.index('Match Route')]).to eq(active_route.title)
        end
      end
    end

    describe 'PATCH update' do
      it 'creates a match for the client on an active-route opportunity' do
        expect do
          patch client_qualified_opportunity_path(client, active_route_opportunity)
        end.to change { ClientOpportunityMatch.where(client: client, opportunity: active_route_opportunity).count }.by(1)

        match = ClientOpportunityMatch.find_by!(client: client, opportunity: active_route_opportunity)
        expect(response).to redirect_to(match_path(match))
      end

      it 'refuses an opportunity on an inactive route' do
        expect do
          patch client_qualified_opportunity_path(client, inactive_route_opportunity)
        end.not_to(change { ClientOpportunityMatch.count })

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'when the user can view but not edit clients' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true) }

    it 'refuses to create a match' do
      expect do
        patch client_qualified_opportunity_path(client, active_route_opportunity)
      end.not_to(change { ClientOpportunityMatch.count })

      expect(response).to redirect_to(root_path)
    end
  end

  context 'when the user cannot view clients' do
    before(:each) { user.roles << create(:role) }

    it 'does not render the client' do
      get client_qualified_opportunities_path(client_id: client.id)

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(opportunity_link(active_route_opportunity))
    end
  end
end
