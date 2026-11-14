###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match decisions reached through a notification link', type: :request do
  let(:route) { MatchRoutes::ProviderOnly.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:participant_role) { create(:shelter_role) }
  let(:hsa_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:shelter_user) { create(:user).tap { |u| u.roles << participant_role } }
  let(:decision) { match.hsa_acknowledges_receipt_decision }
  let(:next_decision) { match.hsa_accepts_client_decision }
  let(:notification) do
    Notifications::MatchRecommendationHousingSubsidyAdmin.create!(match: match, recipient: hsa_user.contact)
  end
  let(:acknowledgment_path) do
    notification_match_decision_acknowledgment_path(notification, match, 'hsa_acknowledges_receipt')
  end

  before do
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.housing_subsidy_admin_contacts << hsa_user.contact
    match.shelter_agency_contacts << shelter_user.contact
    match.dnd_staff_contacts << create(:contact)
    decision.initialize_decision!(send_notifications: false)
  end

  context 'when signed out' do
    it 'sends a decision update to sign in and leaves the step pending' do
      patch notification_match_decision_path(notification, match, 'hsa_acknowledges_receipt'),
            params: { decision: { status: 'acknowledged' } }

      expect(response).to redirect_to(new_user_session_path)
      expect(decision.reload.status).to eq('pending')
    end

    it 'sends an acknowledgment to sign in and leaves the step pending' do
      post acknowledgment_path

      expect(response).to redirect_to(new_user_session_path)
      expect(decision.reload.status).to eq('pending')
    end
  end

  it "refuses a signed-in user acting on a link addressed to another contact's step" do
    sign_in shelter_user

    post acknowledgment_path

    expect(response).to have_http_status(:forbidden)
    expect(decision.reload.status).to eq('pending')
    expect(next_decision.reload.status).to be_nil
  end

  it 'lets the signed-in recipient acknowledge their step' do
    sign_in hsa_user

    post acknowledgment_path

    expect(response).to have_http_status(:ok)
    expect(decision.reload.status).to eq('acknowledged')
    expect(next_decision.reload.status).to eq('pending')
  end
end
