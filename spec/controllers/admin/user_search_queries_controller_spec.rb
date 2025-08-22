# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UserSearchQueriesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #show' do
    it 'assigns the search query and users collection' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:users)).to respond_to(:each)
    end

    it 'uses the search query parameters' do
      get :show, params: { id: search_query.id }
      expect(controller.params[:q]).to eq(search_query.query_params[:q])
    end

    it 'renders the admin/users index template' do
      get :show, params: { id: search_query.id }
      expect(response).to render_template('admin/users/index')
    end

    it 'redirects to new search query when different search term is provided' do
      expect do
        get :show, params: { id: search_query.id, q: 'different search' }
      end.to change(ClientSearchQuery, :count).by(1)

      new_search_query = ClientSearchQuery.last
      expect(response).to redirect_to(admin_user_search_query_path(new_search_query))
      expect(new_search_query.query_params[:q]).to eq('different search')
    end
  end
end
