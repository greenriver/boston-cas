# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client Search Persistence', type: :request do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:client) { create(:client) }
  let!(:identified_client) { create(:identified_client) }
  let!(:deidentified_client) { create(:deidentified_client) }
  let(:default_sort) { { direction: 'desc', sort: 'days_homeless_in_last_three_years' } }

  before do
    sign_in admin
    admin.roles << admin_role
  end

  describe 'Client search persistence' do
    it 'creates a search query and redirects on search' do
      expect do
        post client_search_queries_path, params: { search_form: { q: 'john doe' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(client_search_query_path(search_query, **default_sort))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Deidentified client search persistence' do
    let(:default_sort) { { direction: 'desc', sort: 'non_hmis_clients.days_homeless_in_the_last_three_years' } }
    it 'creates a search query and redirects on search' do
      expect do
        post deidentified_client_search_queries_path, params: { search_form: { q: 'jane doe' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(deidentified_client_search_query_path(search_query, **default_sort))
    end

    it 'displays search results via persisted query URL' do
      search_query = create(:client_search_query, created_by: admin, params: { q: 'test search' })
      get deidentified_client_search_query_path(search_query)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Identified client search persistence' do
    let(:default_sort) { { direction: 'desc', sort: 'non_hmis_clients.days_homeless_in_the_last_three_years' } }
    it 'creates a search query and redirects on search' do
      expect do
        post identified_client_search_queries_path, params: { search_form: { q: 'bob smith' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(identified_client_search_query_path(search_query, **default_sort))
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
        post unavailable_client_search_queries_path, params: { search_form: { q: 'unavailable client' } }
      end.to change(ClientSearchQuery, :count).by(1)

      search_query = ClientSearchQuery.last
      expect(response).to redirect_to(unavailable_client_search_query_path(search_query, **default_sort))
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
      post client_search_queries_path, params: { search_form: { q: 'john doe' } }
      first_query = ClientSearchQuery.last

      # Second identical search should reuse the same query
      expect do
        post client_search_queries_path, params: { search_form: { q: 'john doe' } }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to redirect_to(client_search_query_path(first_query, **default_sort))
    end
  end
end
