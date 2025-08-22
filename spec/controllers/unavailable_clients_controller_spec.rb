# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnavailableClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #index' do
    it 'returns successful response without search' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:clients)).to be_present
    end

    it 'redirects to search query when search is performed' do
      expect do
        get :index, params: { search_form: { q: 'test search' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(unavailable_client_search_query_path(search_query))
    end
  end
end
