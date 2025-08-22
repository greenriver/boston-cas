# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiedClientSearchQueriesController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin_role.can_enter_identified_clients = true
    admin_role.can_manage_identified_clients = true
    admin_role.save!
    admin.roles << admin_role
  end

  describe 'GET #show' do
    it 'assigns the search query and clients collection' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:non_hmis_clients)).to respond_to(:each)
    end

    it 'uses the search query parameters' do
      get :show, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'renders the identified_clients index template' do
      get :show, params: { id: search_query.id }
      expect(response).to render_template('identified_clients/index')
    end

    it 'redirects to new search query when different search term is provided' do
      unique_search = "unique search #{SecureRandom.hex(4)}"
      expect do
        get :show, params: { id: search_query.id, search_form: { q: unique_search } }
      end.to change(ClientSearchQuery, :count).by(1)

      # Extract the UUID from the redirect location
      expect(response).to redirect_to(/identified_client_search_queries\/[\w-]+/)
      redirected_id = response.location.match(/identified_client_search_queries\/([\w-]+)/)[1]
      new_search_query = ClientSearchQuery.find(redirected_id)
      expect(new_search_query.query_params[:q]).to eq(unique_search)
    end
  end
end
