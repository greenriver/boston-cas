# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientSearchQueriesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:client) { create(:client) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #show' do
    it 'assigns the search query and clients collection' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:clients)).to respond_to(:each)
    end

    it 'renders the clients index template' do
      get :show, params: { id: search_query.id }
      expect(response).to render_template('clients/index')
    end

    it 'uses the search query parameters' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'redirects to new search query when different search term is provided' do
      unique_search = "unique search #{SecureRandom.hex(4)}"
      expect do
        get :show, params: { id: search_query.id, search_form: { q: unique_search } }
      end.to change(ClientSearchQuery, :count).by(1)

      # Extract the UUID from the redirect location
      expect(response).to redirect_to(/client_search_queries\/[\w-]+/)
      redirected_id = response.location.match(/client_search_queries\/([\w-]+)/)[1]
      new_search_query = ClientSearchQuery.find(redirected_id)
      expect(new_search_query.query_params[:q]).to eq(unique_search)
    end
  end
end
