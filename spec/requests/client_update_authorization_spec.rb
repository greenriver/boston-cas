###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client update authorization', type: :request do
  describe 'record permission for a rule-based editor' do
    let!(:fits_rules) { create :client, female: true, va_eligible: false, confidential: false }
    let!(:outside_rules) { create :client, female: false, va_eligible: false, confidential: false }
    let(:user) { create :user }
    let!(:data_source) { create :data_source, :deidentified }

    before(:each) do
      [fits_rules, outside_rules].each do |client|
        create :project_client, client_id: client.id, data_source: data_source
      end
      user.roles << create(
        :role,
        can_view_all_clients: true,
        can_edit_clients_based_on_rules: true,
        can_view_client_confidentiality: true,
        can_reject_matches: true,
      )
      user.requirements.create!(rule: create(:rules_female), positive: true)
      expect(Client.editable_by(user)).to contain_exactly(fits_rules)
      sign_in user
    end

    it 'updates a client that fits the user rules' do
      patch client_path(fits_rules), params: { client: { va_eligible: '1' } }

      expect(response).to redirect_to(client_path(fits_rules))
      expect(fits_rules.reload.va_eligible).to be(true)
    end

    it 'does not update a visible client outside the user rules' do
      patch client_path(outside_rules), params: { client: { va_eligible: '1' } }

      expect(response).to redirect_to(root_path)
      expect(outside_rules.reload.va_eligible).to be(false)
    end

    it 'does not change the confidential flag over XHR on a visible client outside the user rules' do
      patch client_path(outside_rules), params: { client: { confidential: 'true' } }, xhr: true

      expect(response).to redirect_to(root_path)
      expect(outside_rules.reload.confidential).to be(false)
    end

    it 'shows the park form and confidential toggle on a client that fits the user rules' do
      get client_path(fits_rules)

      expect(response.body).to include('Park Client')
      expect(response.body).to include('name="client[confidential]"')
    end

    it 'hides the park form and confidential toggle on a visible client outside the user rules' do
      get client_path(outside_rules)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Park Client')
      expect(response.body).not_to include('name="client[confidential]"')
    end

    it 'unparks a client that fits the user rules' do
      parked = create :unavailable_as_candidate_for, client: fits_rules

      delete client_unavailable_on_route_path(fits_rules, parked)

      expect(response).to redirect_to(client_path(fits_rules))
      expect(fits_rules.reload.unavailable_as_candidate_fors).to be_empty
    end

    it 'does not unpark a visible client outside the user rules' do
      parked = create :unavailable_as_candidate_for, client: outside_rules

      delete client_unavailable_on_route_path(outside_rules, parked)

      expect(response).to redirect_to(root_path)
      expect(outside_rules.reload.unavailable_as_candidate_fors).to contain_exactly(parked)
    end
  end

  describe 'field permissions for a client editor' do
    let(:editor) { create :user }

    before(:each) do
      editor.roles << create(:role, can_view_all_clients: true, can_edit_all_clients: true)
      sign_in editor
    end

    it 'keeps the confidential flag set over XHR without confidentiality permission' do
      client = create :client, confidential: true

      patch client_path(client), params: { client: { confidential: 'false' } }, xhr: true

      expect(response).to have_http_status(:ok)
      expect(client.reload.confidential).to be(true)
    end

    it 'ignores prevent_matching_until without match reject permission' do
      client = create :client

      patch client_path(client), params: { client: { prevent_matching_until: (Date.current + 2.days).to_s } }

      expect(client.reload.unavailable_as_candidate_fors.count).to eq(0)
    end

    context 'with confidentiality and match reject permissions' do
      before(:each) do
        editor.roles << create(:role, name: 'extra', can_view_client_confidentiality: true, can_reject_matches: true)
      end

      it 'sets the confidential flag over XHR' do
        client = create :client, confidential: false

        patch client_path(client), params: { client: { confidential: 'true' } }, xhr: true

        expect(response).to have_http_status(:ok)
        expect(client.reload.confidential).to be(true)
      end

      it 'parks the client on every route' do
        client = create :client

        patch client_path(client), params: { client: { prevent_matching_until: (Date.current + 2.days).to_s } }

        expect(client.reload.unavailable_as_candidate_fors.count).to eq(MatchRoutes::Base.all_routes.count)
      end

      it 'redirects without parking when prevent_matching_until is not a date' do
        client = create :client

        patch client_path(client), params: { client: { prevent_matching_until: 'not-a-date' } }

        expect(response).to redirect_to(client_path(client))
        expect(client.reload.unavailable_as_candidate_fors.count).to eq(0)
      end
    end
  end
end
