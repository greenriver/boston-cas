# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiedClientsController, type: :controller do
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

  describe 'GET #search' do
    it 'assigns the search query and clients collection' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:non_hmis_clients)).to respond_to(:each)
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'renders the identified_clients index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('identified_clients/index')
    end
  end
end
