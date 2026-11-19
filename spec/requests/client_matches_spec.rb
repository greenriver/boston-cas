###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client match pages', type: :request do
  let!(:client) { create :client, first_name: 'Visible', last_name: 'Person' }
  let(:user) { create :user }

  before { sign_in user }

  context 'when the user can view all matches but cannot view clients' do
    before { user.roles << create(:role, name: 'matches only', can_view_all_matches: true) }

    it 'returns not found for the active matches page and does not render the name' do
      get client_matches_path(client)

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(client.name)
    end

    it 'returns not found for the closed matches page and does not render the name' do
      get client_closed_matches_path(client)

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include(client.name)
    end
  end

  context 'when the user can view all matches and all clients' do
    before { user.roles << create(:role, name: 'matches and clients', can_view_all_matches: true, can_view_all_clients: true) }

    it 'renders the active matches page with the client name' do
      get client_matches_path(client)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Matches for Visible Person')
    end

    it 'renders the closed matches page with the client name' do
      get client_closed_matches_path(client)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Matches for Visible Person')
    end
  end

  context 'when the user can view clients but not all matches' do
    before { user.roles << create(:role, name: 'clients only', can_view_all_clients: true) }

    it 'redirects away from the active matches page' do
      get client_matches_path(client)

      expect(response).to redirect_to(root_path)
    end

    it 'redirects away from the closed matches page' do
      get client_closed_matches_path(client)

      expect(response).to redirect_to(root_path)
    end
  end
end
