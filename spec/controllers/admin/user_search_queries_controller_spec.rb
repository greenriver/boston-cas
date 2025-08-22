# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserSearchQueriesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'POST #create' do
    it 'creates a search query with q and sort/direction and redirects to users#search' do
      expect do
        post :create, params: { q: 'alpha', sort: 'last_name', direction: 'asc' }
      end.to change(ClientSearchQuery, :count).by(1)

      query = ClientSearchQuery.last
      expect(query.query_params[:q]).to eq('alpha')
      expect(query.query_params[:sort]).to eq('last_name')
      expect(query.query_params[:direction]).to eq('asc')
      expect(response).to redirect_to(admin_user_search_query_path(id: query.id))
    end

    it 'reuses an existing search query for identical parameters' do
      post :create, params: { q: 'alpha', sort: 'last_name', direction: 'asc' }
      first_query = ClientSearchQuery.last

      expect do
        post :create, params: { q: 'alpha', sort: 'last_name', direction: 'asc' }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to redirect_to(admin_user_search_query_path(id: first_query.id))
    end
  end
end
