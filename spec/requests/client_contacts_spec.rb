###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client default contacts', type: :request do
  let!(:client) { create :client }
  let!(:existing_contact) { create :contact }
  let!(:existing_join) { ClientContact.create!(client: client, contact: existing_contact, shelter_agency: true) }
  let(:user) { create :user }
  let(:replacement_params) do
    { client_contacts: { shelter_agency_contact_ids: [user.contact.id.to_s] } }
  end

  let(:editable_field_marker) { 'data-input-name="client_contacts[shelter_agency_contact_ids][]"' }

  def shelter_agency_contact_ids
    ClientContact.where(client_id: client.id, shelter_agency: true).distinct.pluck(:contact_id)
  end

  before(:each) { sign_in user }

  context 'when the user has no client permissions' do
    it 'returns 404 for the edit page' do
      get edit_client_contacts_path(client)

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for update and keeps the existing default contacts' do
      patch client_contacts_path(client), params: replacement_params, xhr: true

      expect(response).to have_http_status(:not_found)
      expect(shelter_agency_contact_ids).to contain_exactly(existing_contact.id)
    end
  end

  context 'when the user can view the client but cannot edit match contacts' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true) }

    it 'renders the read-only edit page with the existing contact' do
      get edit_client_contacts_path(client)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(existing_contact.email)
      expect(response.body).not_to include(editable_field_marker)
    end

    it 'redirects update to root and keeps the existing default contacts' do
      patch client_contacts_path(client), params: replacement_params

      expect(response).to redirect_to(root_path)
      expect(shelter_agency_contact_ids).to contain_exactly(existing_contact.id)
    end

    it 'returns 403 for a modal form update and keeps the existing default contacts' do
      patch client_contacts_path(client), params: replacement_params, xhr: true

      expect(response).to have_http_status(:forbidden)
      expect(shelter_agency_contact_ids).to contain_exactly(existing_contact.id)
    end
  end

  context 'when the user can edit match contacts but cannot edit the client' do
    before(:each) { user.roles << create(:role, can_view_all_clients: true, can_edit_match_contacts: true) }

    it 'returns 403 for a modal form update and keeps the existing default contacts' do
      patch client_contacts_path(client), params: replacement_params, xhr: true

      expect(response).to have_http_status(:forbidden)
      expect(shelter_agency_contact_ids).to contain_exactly(existing_contact.id)
    end
  end

  context 'when the user can edit all clients but cannot edit match contacts' do
    before(:each) { user.roles << create(:role, can_edit_all_clients: true) }

    it 'renders editable contact fields on the edit page' do
      get edit_client_contacts_path(client)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(editable_field_marker)
    end

    it 'replaces the default contacts through the modal form' do
      patch client_contacts_path(client), params: replacement_params, xhr: true

      expect(response).to have_http_status(:ok)
      expect(shelter_agency_contact_ids).to contain_exactly(user.contact.id)
    end

    it 'replaces the default contacts through the full-page form and redirects to the client' do
      patch client_contacts_path(client), params: replacement_params

      expect(response).to redirect_to(client_path(client))
      expect(flash[:notice]).to eq('Default Client Contacts updated')
      expect(shelter_agency_contact_ids).to contain_exactly(user.contact.id)
    end
  end
end
