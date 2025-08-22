# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveMatchSearchQueriesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
    allow(MatchRoutes::Base).to receive(:filterable_routes).and_return({ 'Default' => 'MatchRoutes::Default' })
  end

  describe 'GET #show' do
    it 'assigns the search query' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
    end

    it 'uses the search query parameters' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'applies sort parameters from saved search query' do
      search_with_sort = create(:client_search_query,
                                params: { q: 'test', sort: 'last_name', direction: 'desc' },
                                created_by: admin)

      get :show, params: { id: search_with_sort.id }

      expect(assigns(:column)).to eq('last_name')
      expect(assigns(:direction)).to eq('desc')
    end

    it 'renders the active_matches index template' do
      get :show, params: { id: search_query.id }
      expect(response).to render_template('active_matches/index')
    end

    it 'redirects to new search query when different search term is provided' do
      unique_search = "unique search #{SecureRandom.hex(4)}"
      expect do
        get :show, params: { id: search_query.id, q: unique_search }
      end.to change(ClientSearchQuery, :count).by(1)

      # Extract the UUID from the redirect location
      expect(response).to redirect_to(/active_match_search_queries\/[\w-]+/)
      redirected_id = response.location.match(/active_match_search_queries\/([\w-]+)/)[1]
      new_search_query = ClientSearchQuery.find(redirected_id)
      expect(new_search_query.query_params[:q]).to eq(unique_search)
    end

    it 'does not redirect when only filter parameters change' do
      expect do
        get :show, params: { id: search_query.id, current_route: 'MatchRoutes::Default' }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to render_template('active_matches/index')
    end

    it 'redirects to main index when empty search is submitted' do
      get :show, params: { id: search_query.id, q: '   ', current_route: 'MatchRoutes::Default' }

      expect(response).to redirect_to(active_matches_path(current_route: 'MatchRoutes::Default'))
    end

    it 'preserves filter and sort parameters when empty search is submitted' do
      # Create a search query with saved filters and sort
      search_with_filters = create(:client_search_query,
                                   params: {
                                     q: 'test',
                                     current_route: 'MatchRoutes::Provider',
                                     current_step: 'step1',
                                     sort: 'last_name',
                                     direction: 'asc',
                                   },
                                   created_by: admin)

      get :show, params: { id: search_with_filters.id, q: '   ', current_program: 'new_program' }

      expect(response).to redirect_to(active_matches_path(
                                        current_route: 'MatchRoutes::Provider',
                                        current_step: 'step1',
                                        sort: 'last_name',
                                        direction: 'asc',
                                        current_program: 'new_program',
                                      ))
    end
  end
end
