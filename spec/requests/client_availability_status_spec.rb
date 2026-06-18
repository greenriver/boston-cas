###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Client Availability Status', type: :request do
  let!(:data_source) { create(:data_source, :deidentified) }
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:client) { create(:client) }
  let!(:project_client) { create(:project_client, client_id: client.id, data_source: data_source) }
  let(:priority) { create(:priority_vispdat_priority) }
  let!(:default_route) { MatchRoutes::Default.first || create(:default_route, match_prioritization: priority) }
  let!(:provider_route) { MatchRoutes::ProviderOnly.first || create(:provider_route, match_prioritization: priority) }

  before do
    default_route.update(active: true)
    provider_route.update(active: true)
    admin.roles << admin_role
    sign_in admin
  end

  describe 'GET /clients/:id' do
    context 'when client is unavailable due to active match' do
      let(:program) { create(:program, match_route: default_route) }
      let(:sub_program) { create(:sub_program, program: program) }
      let(:voucher) { create(:voucher, sub_program: sub_program) }
      let(:opportunity) { create(:opportunity, voucher: voucher) }
      let!(:active_match) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity,
          match_route: default_route,
          active: true,
          closed: false,
          created_at: 30.days.ago,
        )
      end

      let!(:unavailable_record) do
        create(
          :unavailable_as_candidate_for,
          :active_match,
          client: client,
          match_route_type: default_route.class.name,
          match: active_match,
          created_at: 30.days.ago,
        )
      end

      it 'displays the active match information' do
        get client_path(client)

        aggregate_failures 'checking response' do
          expect(response).to have_http_status(:success)
          expect(response.body).to include(default_route.title)
          expect(response.body).to include('Active match')
          expect(response.body).to include("started: #{active_match.created_at.to_date}")
        end
      end

      it 'loads data efficiently with minimal queries' do
        queries = []
        query_counter = lambda do |_name, _started, _finished, _unique_id, payload|
          queries << payload[:sql] unless payload[:name] == 'SCHEMA'
        end

        ActiveSupport::Notifications.subscribed(query_counter, 'sql.active_record') do
          get client_path(client)
        end

        unavailable_queries = queries.select { |q| q.include?('unavailable_as_candidate_fors') }
        # Queries: preload (unavailable_fors + routes + matches + match_routes) + exists? check + editable_by check
        expect(unavailable_queries.size).to be <= 7
      end
    end

    context 'when client is unavailable with other reasons' do
      let!(:parked_record) do
        create(
          :unavailable_as_candidate_for,
          :with_expiration,
          client: client,
          match_route_type: default_route.class.name,
          reason: UnavailableAsCandidateFor::PARKED_TEXT,
          created_at: 10.days.ago,
          expires_at: 20.days.from_now,
        )
      end

      it 'displays the reason, created date, and expiration' do
        get client_path(client)

        aggregate_failures 'checking response' do
          expect(response).to have_http_status(:success)
          expect(response.body).to include(default_route.title)
          expect(response.body).to include(UnavailableAsCandidateFor::PARKED_TEXT)
          expect(response.body).to include("created: #{parked_record.created_at.to_date}")
          expect(response.body).to include("expires: #{parked_record.expires_at.to_date}")
        end
      end
    end

    context 'when client is unavailable on multiple routes' do
      let(:program_default) { create(:program, match_route: default_route) }
      let(:program_provider) { create(:program, match_route: provider_route) }
      let(:sub_program_default) { create(:sub_program, program: program_default) }
      let(:sub_program_provider) { create(:sub_program, program: program_provider) }
      let(:voucher_default) { create(:voucher, sub_program: sub_program_default) }
      let(:voucher_provider) { create(:voucher, sub_program: sub_program_provider) }
      let(:opportunity_default) { create(:opportunity, voucher: voucher_default) }
      let(:opportunity_provider) { create(:opportunity, voucher: voucher_provider) }

      let!(:active_match) do
        create(
          :client_opportunity_match,
          client: client,
          opportunity: opportunity_default,
          match_route: default_route,
          active: true,
          closed: false,
          created_at: 15.days.ago,
        )
      end

      let!(:unavailable_active) do
        create(
          :unavailable_as_candidate_for,
          :active_match,
          client: client,
          match_route_type: default_route.class.name,
          match: active_match,
          created_at: 15.days.ago,
        )
      end

      let!(:unavailable_parked) do
        create(
          :unavailable_as_candidate_for,
          client: client,
          match_route_type: provider_route.class.name,
          reason: UnavailableAsCandidateFor::PARKED_TEXT,
          created_at: 5.days.ago,
          expires_at: nil,
        )
      end

      it 'displays both routes with appropriate information' do
        get client_path(client)

        aggregate_failures 'checking both routes' do
          expect(response).to have_http_status(:success)
          expect(response.body).to include(default_route.title)
          expect(response.body).to include(provider_route.title)
          expect(response.body).to include('Active match')
          expect(response.body).to include("started: #{active_match.created_at.to_date}")
          expect(response.body).to include(UnavailableAsCandidateFor::PARKED_TEXT)
        end
      end
    end

    context 'when client has active match but no match record on unavailable entry' do
      let!(:unavailable_record) do
        create(
          :unavailable_as_candidate_for,
          client: client,
          match_route_type: default_route.class.name,
          reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT,
          match: nil,
        )
      end

      it 'handles missing match gracefully' do
        get client_path(client)

        aggregate_failures 'checking response' do
          expect(response).to have_http_status(:success)
          expect(response.body).to include('Active match')
          expect(response).not_to be_server_error
        end
      end
    end
  end
end
