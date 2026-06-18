###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnavailableClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }

  before do
    authenticate admin
    admin.roles << admin_role
    # Ensure the user can view clients
    allow_any_instance_of(User).to receive(:can_view_all_clients?).and_return(true)
    # Also ensure the controller passes require_some_clients_viewable!
    allow_any_instance_of(ClientsController).to receive(:require_some_clients_viewable!).and_return(true)
  end

  describe 'GET #index' do
    it 'returns successful response without search' do
      # seed a client so the list has data
      create(:client, available: false)
      get :index
      expect(response).to have_http_status(:success)
      # On index, ClientsController assigns @clients via filter_data
      expect(assigns(:clients)).to be_present
    end
  end
end
