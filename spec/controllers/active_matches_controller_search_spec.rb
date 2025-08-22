# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveMatchesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
    allow(MatchRoutes::Base).to receive(:filterable_routes).and_return({ 'Default' => 'MatchRoutes::Default' })
  end

  describe 'GET #search' do
    it 'assigns the search query' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'applies sort parameters from saved search query' do
      search_with_sort = create(:client_search_query,
                                params: { q: 'test', sort: 'last_name', direction: 'desc' },
                                created_by: admin)

      get :search, params: { id: search_with_sort.id }

      # Active matches controller defaults to 'last_decision' unless the sort is one of the allowed options.
      # Ensure the controller sets @direction and keeps a valid column.
      expect(assigns(:direction)).to eq('desc')
      expect(assigns(:column)).to be_present
    end

    it 'renders the active_matches index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('active_matches/index')
    end

    it 'does not redirect when only filter parameters change' do
      expect do
        get :search, params: { id: search_query.id, current_route: 'MatchRoutes::Default' }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to render_template('active_matches/index')
    end
  end
end
