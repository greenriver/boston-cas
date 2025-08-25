# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClosedMatchesController, type: :controller do
  render_views
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }
  let!(:program) { create(:program) }
  let!(:client1) { create(:client) }
  let!(:client2) { create(:client) }
  let!(:voucher1) { create(:voucher, sub_program: create(:sub_program, program: program)) }
  let!(:voucher2) { create(:voucher, sub_program: create(:sub_program, program: program)) }
  let!(:opportunity1) { create(:opportunity, voucher: voucher1) }
  let!(:opportunity2) { create(:opportunity, voucher: voucher2) }

  # Create a route first, then use it in the matches
  let!(:match_route) { create(:default_route) }
  let!(:closed_match_1) { create(:client_opportunity_match, client: client1, opportunity: opportunity1, match_route: match_route, closed: true, active: false) }
  let!(:closed_match_2) { create(:client_opportunity_match, client: client2, opportunity: opportunity2, match_route: match_route, closed: true, active: false) }

  before do
    allow_any_instance_of(ClosedMatchesController).to receive(:setup_notifier)
    admin.roles << admin_role
    allow(MatchRoutes::Base).to receive(:filterable_routes).and_return({ 'Default' => 'MatchRoutes::Default' })
  end

  describe 'GET #search' do
    it 'assigns the search query' do
      authenticate admin
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
    end

    it 'uses the search query parameters' do
      authenticate admin
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'renders the closed_matches index template' do
      authenticate admin
      get :search, params: { id: search_query.id }
      expect(response).to render_template('closed_matches/index')
    end

    it 'does not redirect when only filter parameters change' do
      authenticate admin
      expect do
        get :search, params: { id: search_query.id, current_route: 'MatchRoutes::Default' }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to render_template('closed_matches/index')
    end

    it 'applies sort parameters from params and shows the opportunities' do
      authenticate admin
      allow(MatchRoutes::Base).to receive(:filterable_routes).and_return({ 'Default' => 'MatchRoutes::Default' })
      get :search, params: { id: search_query.id, sort: 'last_decision', direction: 'asc' }
      expect(response.body).to include(opportunity1.voucher.sub_program.program.name)
      expect(response.body).to include(opportunity2.voucher.sub_program.program.name)
    end

    it 'accepts step, program, and contact filters without creating a new search query and shows filtered results' do
      authenticate admin
      expect do
        get :search, params: { id: search_query.id, current_step: 'some_step', current_program: program.id, current_contact_type: 'hsp_contacts' }
      end.not_to change(ClientSearchQuery, :count)
      expect(response.body).to include('Closed Matches')
      # Page should still show opportunities content under these filters
      expect(response.body).to include(opportunity1.voucher.sub_program.program.name)
    end
  end
end
