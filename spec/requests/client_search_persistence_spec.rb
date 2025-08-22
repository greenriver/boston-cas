# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client Search Persistence', type: :request do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }

  before do
    sign_in admin
    admin.roles << admin_role
  end

  describe 'Client search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        get clients_path, params: { search_form: { q: 'john doe' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(client_search_query_path(search_query))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Deidentified client search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        get deidentified_clients_path, params: { search_form: { q: 'jane doe' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(deidentified_client_search_query_path(search_query))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get deidentified_client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Identified client search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        get identified_clients_path, params: { search_form: { q: 'bob smith' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(identified_client_search_query_path(search_query))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get identified_client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Admin user search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        get admin_users_path, params: { q: 'admin user' }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(admin_user_search_query_path(search_query))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get admin_user_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Unavailable client search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        get unavailable_clients_path, params: { search_form: { q: 'unavailable client' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(unavailable_client_search_query_path(search_query))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get unavailable_client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Search query reuse' do
    it 'reuses existing search query for identical searches' do
      # First search
      get clients_path, params: { search_form: { q: 'john doe' } }
      first_query = ClientSearchQuery.last

      # Second identical search should reuse the same query
      expect do
        get clients_path, params: { search_form: { q: 'john doe' } }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to redirect_to(client_search_query_path(first_query))
    end
  end
end
