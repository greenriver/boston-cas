###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match activation is limited to the eligible client list', type: :request do
  let!(:contact) { create :macbeth }
  let!(:user) { create :user, contact: contact }
  let!(:prioritization_scheme) { create :priority_days_homeless }
  let!(:route) do
    route = MatchRoutes::Default.first
    route.update(match_prioritization: prioritization_scheme)
    route
  end
  let!(:match) { create :client_opportunity_match, active: false, match_route: route }
  let!(:project_client) { create :project_client, client_id: match.client.id }
  let(:opportunity) { match.opportunity }
  let(:eligible_client) { match.client }
  let!(:ineligible_client) do
    client = create :client, available: false
    create :project_client, client_id: client.id
    client
  end
  let!(:rejected_client) do
    client = create :client, available: true
    create :project_client, client_id: client.id
    RejectedMatch.create!(client_id: client.id, opportunity_id: opportunity.id)
    client
  end
  let!(:other_eligible_client) do
    client = create :client, available: true
    create :project_client, client_id: client.id
    client
  end
  let!(:role) do
    create :role,
           can_see_all_alternate_matches: true,
           can_edit_assigned_programs: true,
           can_view_assigned_programs: true,
           can_activate_matches: true
  end

  before(:each) do
    sign_in user
    EntityViewPermission.create(entity: match.program, agency: user.agency, editable: true)
    user.roles << role
  end

  def eligible_ids
    opportunity.matching_clients(Client.available_for_matching(route)).pluck(:id)
  end

  it 'starts with the eligible list excluding unavailable and rejected clients and the user seeing no clients' do
    expect(eligible_ids).to include(eligible_client.id, other_eligible_client.id)
    expect(eligible_ids).not_to include(ineligible_client.id, rejected_client.id)
    expect(Client.available_for_matching(route).pluck(:id)).to include(rejected_client.id)
    expect(Client.visible_by(user)).to be_empty
  end

  context 'when the route allows multiple active matches' do
    before { route.update!(allow_multiple_active_matches: true) }

    it 'does not activate a match for an available client rejected for the opportunity' do
      expect do
        post opportunity_matches_path(opportunity), params: { checkboxes: { rejected_client.id.to_s => '1' } }
      end.not_to(change { ClientOpportunityMatch.where(client: rejected_client, opportunity: opportunity).count })
    end

    it 'activates only the eligible client when posted together with a rejected client' do
      post opportunity_matches_path(opportunity), params: { checkboxes: { eligible_client.id.to_s => '1', rejected_client.id.to_s => '1' } }

      expect(ClientOpportunityMatch.find_by(client: eligible_client, opportunity: opportunity)&.active).to eq(true)
      expect(ClientOpportunityMatch.where(client: rejected_client, opportunity: opportunity)).to be_empty
    end

    it 'activates a match for a client on the eligible list' do
      post opportunity_matches_path(opportunity), params: { checkboxes: { eligible_client.id.to_s => '1' } }

      expect(ClientOpportunityMatch.find_by(client: eligible_client, opportunity: opportunity)&.active).to eq(true)
    end
  end

  context 'when the route allows a single active match' do
    it 'does not activate matches through the checkbox form' do
      post opportunity_matches_path(opportunity), params: { checkboxes: { eligible_client.id.to_s => '1' } }

      expect(match.reload.active).to eq(false)
    end

    it 'keeps the current active match when the requested client is available but rejected for the opportunity' do
      match.activate!
      patch opportunity_match_path(opportunity, rejected_client.id)

      expect(response).to redirect_to(root_path)
      expect(match.reload.active).to eq(true)
      expect(ClientOpportunityMatch.where(client: rejected_client)).to be_empty
    end

    it 'keeps the current active match when the requested client is unavailable for matching' do
      match.activate!
      patch opportunity_match_path(opportunity, ineligible_client.id)

      expect(response).to redirect_to(root_path)
      expect(match.reload.active).to eq(true)
      expect(ClientOpportunityMatch.where(client: ineligible_client)).to be_empty
    end

    it 'leaves the active match untouched when the requested client already holds it' do
      route.update!(should_prevent_multiple_matches_per_client: false)
      match.activate!
      patch opportunity_match_path(opportunity, eligible_client.id)

      expect(response).to redirect_to(root_path)
      expect(match.reload.active).to eq(true)
      expect(match.closed_reason).to be_nil
      expect(ClientOpportunityMatch.where(client: eligible_client, opportunity: opportunity).count).to eq(1)
    end

    it 'cancels the current active match and activates the requested eligible client' do
      match.activate!
      patch opportunity_match_path(opportunity, other_eligible_client.id)

      expect(match.reload.closed_reason).to eq('canceled')
      expect(ClientOpportunityMatch.find_by(client: other_eligible_client, opportunity: opportunity)&.active).to eq(true)
    end
  end

  describe 'the CSV export' do
    context 'when the user has the activate matches permission' do
      it 'returns the export content' do
        get opportunity_matches_path(opportunity, format: :csv)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Remote ID')
      end

      it 'returns the export content when the voucher is unavailable' do
        opportunity.voucher.update!(available: false)
        get opportunity_matches_path(opportunity, format: :csv)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Remote ID')
      end
    end

    context 'when the user lacks the activate matches permission' do
      before { role.update!(can_activate_matches: false) }

      it 'redirects to root without the export content' do
        get opportunity_matches_path(opportunity, format: :csv)

        expect(response).to redirect_to(root_path)
        expect(response.body).not_to include('Remote ID')
      end
    end
  end
end
