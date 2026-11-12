###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match contacts submitted with a decision update', type: :request do
  let(:route) { MatchRoutes::Default.first }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }
  let(:voucher) { create(:voucher, sub_program: sub_program) }
  let(:opportunity) { create(:opportunity, voucher: voucher) }
  let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
  let(:admin_user) { create(:user).tap { |u| u.roles << create(:admin_role) } }
  let(:original_hsa) { create(:contact) }
  let(:original_ssp) { create(:contact) }
  let(:other) { create(:contact) }
  let(:decision) { match.approve_match_housing_subsidy_admin_decision }

  before do
    # Client#non_hmis? queries DataSource.non_hmis, which has no seed row in the test
    # database, so it raises NoMethodError on nil.id unless stubbed.
    allow_any_instance_of(Client).to receive(:non_hmis?).and_return(false)
    match.housing_subsidy_admin_contacts << original_hsa
    match.ssp_contacts << original_ssp
    decision.initialize_decision!(send_notifications: false)
    sign_in admin_user
  end

  it 'records the decision and ignores submitted contacts, even from a user who can edit match contacts' do
    patch match_decision_path(match, 'approve_match_housing_subsidy_admin'),
          params: {
            decision: { status: 'accepted' },
            match_contacts: { ssp_contact_ids: [other.id], housing_subsidy_admin_contact_ids: [other.id] },
          }

    match.reload
    aggregate_failures do
      expect(decision.reload.status).to eq('accepted')
      expect(match.ssp_contacts).to contain_exactly(original_ssp)
      expect(match.housing_subsidy_admin_contacts).to contain_exactly(original_hsa)
    end
  end
end
