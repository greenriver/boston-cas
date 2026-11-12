###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match decision acknowledgments', type: :request do
  let(:route) { MatchRoutes::ProviderOnly.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:participant_role) { create(:shelter_role) }
  let(:hsa_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:shelter_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:program_viewer) do
    create(:user).tap { |u| u.roles << create(:role, can_view_assigned_programs: true) }
  end
  let(:decision) { match.hsa_acknowledges_receipt_decision }
  let(:next_decision) { match.hsa_accepts_client_decision }
  let(:acknowledgment_path) { match_decision_acknowledgment_path(match, 'hsa_acknowledges_receipt') }

  before do
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.housing_subsidy_admin_contacts << hsa_user.contact
    match.shelter_agency_contacts << shelter_user.contact
    match.dnd_staff_contacts << create(:contact)
    EntityViewPermission.create!(entity: program, agency: program_viewer.agency, editable: false)
    decision.initialize_decision!(send_notifications: false)
  end

  it 'refuses a user who sees the match only through program visibility' do
    sign_in program_viewer

    post acknowledgment_path

    expect(response).to have_http_status(:forbidden)
    expect(decision.reload.status).to eq('pending')
    expect(next_decision.reload.status).to be_nil
  end

  it 'refuses a shelter agency contact' do
    sign_in shelter_user

    post acknowledgment_path

    expect(response).to have_http_status(:forbidden)
    expect(decision.reload.status).to eq('pending')
    expect(next_decision.reload.status).to be_nil
  end

  context 'when signed in as the HSA' do
    before { sign_in hsa_user }

    it 'refuses a closed match' do
      match.update!(closed: true, closed_reason: 'canceled')

      post acknowledgment_path

      expect(response).to have_http_status(:forbidden)
      expect(decision.reload.status).to eq('pending')
    end

    it 'refuses a step that is already acknowledged' do
      decision.update!(status: 'acknowledged')
      next_decision.initialize_decision!(send_notifications: false)
      next_decision.update!(status: 'accepted')

      post acknowledgment_path

      expect(response).to have_http_status(:forbidden)
      expect(next_decision.reload.status).to eq('accepted')
    end

    it 'acknowledges a pending step and starts the next step' do
      post acknowledgment_path

      expect(response).to have_http_status(:ok)
      expect(decision.reload.status).to eq('acknowledged')
      expect(next_decision.reload.status).to eq('pending')
    end

    it 'returns not found for an unknown step' do
      post match_decision_acknowledgment_path(match, 'not_a_step')

      expect(response).to have_http_status(:not_found)
    end
  end
end
