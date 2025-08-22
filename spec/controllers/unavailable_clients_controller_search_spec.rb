# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnavailableClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:client) { create(:client) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #search' do
    it 'assigns the search query and clients collection' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:clients)).to respond_to(:each)
    end

    it 'renders the unavailable_clients index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('unavailable_clients/index')
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end
  end
end
