###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Destroy status submitted on a decision', type: :request do
  let(:route) { MatchRoutes::ProviderOnly.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:decision) { match.hsa_acknowledges_receipt_decision }
  let(:decision_path) { match_decision_path(match, 'hsa_acknowledges_receipt') }

  before do
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.housing_subsidy_admin_contacts << hsa_user.contact
    decision.initialize_decision!(send_notifications: false)
    sign_in hsa_user
  end

  context 'when the HSA cannot delete matches' do
    let(:hsa_user) { create(:user).tap { |u| u.roles << create(:shelter_role) } }

    it 'leaves the step pending and keeps the match' do
      patch decision_path, params: { decision: { status: 'destroy' } }

      expect(response).to redirect_to(match_path(match))
      expect(decision.reload.status).to eq('pending')
      expect(ClientOpportunityMatch.exists?(match.id)).to be(true)
    end
  end

  context 'when the HSA can delete matches' do
    let(:hsa_user) { create(:user).tap { |u| u.roles << create(:shelter_role, can_delete_matches: true) } }

    it 'deletes the match' do
      patch decision_path, params: { decision: { status: 'destroy' } }

      expect(response).to redirect_to(opportunity_matches_path(opportunity))
      expect(ClientOpportunityMatch.exists?(match.id)).to be(false)
    end
  end
end
