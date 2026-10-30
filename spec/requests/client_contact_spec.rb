###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client email preferences', type: :request do
  let!(:client) { create :client, email: 'original@example.com', send_emails: false }
  let(:user) { create :user }
  let(:new_attributes) { { contact_info: { email: 'changed@example.com', send_emails: '1' } } }

  before(:each) { sign_in user }

  context 'when the user has no client permissions' do
    it 'returns 404 for the edit page' do
      get edit_client_contact_path(client)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for update and leaves the email and preference unchanged' do
      patch client_contact_path(client), params: new_attributes

      expect(response).to have_http_status(:not_found)
      expect(client.reload.attributes.slice('email', 'send_emails')).
        to eq('email' => 'original@example.com', 'send_emails' => false)
    end
  end

  context 'when the user can view but not edit the client' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true) }

    it 'returns 404 for the edit page' do
      get edit_client_contact_path(client)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for update and leaves the email unchanged' do
      patch client_contact_path(client), params: new_attributes

      expect(response).to have_http_status(:not_found)
      expect(client.reload.email).to eq('original@example.com')
    end
  end

  context 'when the user can edit all clients' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true, can_edit_all_clients: true) }

    it 'renders the edit page with the email' do
      get edit_client_contact_path(client)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('original@example.com')
    end

    it 'updates the email and preference and redirects to the client' do
      patch client_contact_path(client), params: new_attributes

      expect(response).to redirect_to(client_path(client))
      expect(client.reload.attributes.slice('email', 'send_emails')).
        to eq('email' => 'changed@example.com', 'send_emails' => true)
    end
  end
end
