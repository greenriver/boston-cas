###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports::HousedAddresses', type: :request do
  let!(:client) { create(:client, last_name: 'Housedperson') }
  let!(:match) do
    create(
      :client_opportunity_match,
      client: client,
      closed: true,
      active: false,
      closed_reason: 'success',
    )
  end
  let!(:decision) do
    create(
      :match_decisions_match_recommendation_dnd_staff,
      match: match,
      client_move_in_date: 1.month.ago.to_date,
    )
  end

  describe 'GET /reports/housed_addresses' do
    it 'redirects a user without can_view_reports to the root path' do
      sign_in create(:user)

      get reports_housed_addresses_path

      expect(response).to redirect_to(root_path)
    end

    it 'lists a housed client the user can see' do
      role = create(:role, can_view_reports: true, can_view_all_clients: true)
      sign_in create(:user, roles: [role])

      get reports_housed_addresses_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Housedperson')
    end

    it 'omits a housed client the user cannot see' do
      role = create(:role, can_view_reports: true)
      sign_in create(:user, roles: [role])

      get reports_housed_addresses_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Housedperson')
    end

    context 'when the user can see clients based on rules' do
      let(:other_client) { create(:client, last_name: 'Otherhoused', female: false) }
      let(:other_match) do
        create(
          :client_opportunity_match,
          client: other_client,
          closed: true,
          active: false,
          closed_reason: 'success',
        )
      end

      before do
        client.update!(female: true)
        create(
          :match_decisions_match_recommendation_dnd_staff,
          match: other_match,
          client_move_in_date: 1.month.ago.to_date,
        )
        role = create(:role, can_view_reports: true, can_edit_clients_based_on_rules: true)
        user = create(:user, roles: [role])
        user.requirements << create(:requirement, rule: create(:rules_female), positive: true)
        sign_in user
      end

      it 'lists only housed clients that meet the user requirements' do
        get reports_housed_addresses_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Housedperson')
        expect(response.body).not_to include('Otherhoused')
      end
    end
  end
end
