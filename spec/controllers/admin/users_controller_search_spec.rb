###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:user_a) { create(:user, first_name: 'Ada', last_name: 'Lovelace', email: 'ada@example.com') }
  let!(:user_b) { create(:user, first_name: 'Grace', last_name: 'Hopper', email: 'grace@example.com') }
  let!(:inactive_user) { create(:user, first_name: 'Inactive', last_name: 'User', email: 'inactive@example.com', active: false) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #search' do
    it 'assigns the search query and users collection' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:users)).to respond_to(:each)
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(controller.params[:id]).to eq(search_query.id)
    end

    it 'renders the admin/users index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('admin/users/index')
    end

    it 'filters users and inactive_users collections using persisted q' do
      q = 'hopper'
      persisted = create(:client_search_query, created_by: admin, params: { q: q })

      get :search, params: { id: persisted.id }

      expect(assigns(:query)).to eq(q)
      # active users filtered
      expect(assigns(:users).map(&:email)).to include('grace@example.com')
      expect(assigns(:users).map(&:email)).not_to include('ada@example.com')
      # inactive users filtered
      expect(assigns(:inactive_users).map(&:email)).not_to include('inactive@example.com') if assigns(:inactive_users).present?
    end
  end
end
