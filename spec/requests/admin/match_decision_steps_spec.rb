###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::MatchDecisionSteps', type: :request do
  let!(:admin_role) { create(:admin_role, can_manage_config: true) }
  let!(:admin) { create(:user) }
  let(:route) { create(:default_route) }
  let(:step) { create(:match_decision_step, route: route, decision_type: 'MatchDecisions::SomeStep') }

  before do
    admin.roles << admin_role
    sign_in admin
  end

  describe 'GET edit' do
    it 'shows a human-readable step title and its current default_referral_result selected' do
      step.update!(default_referral_result: MatchDecisionReasons::Base::CLIENT_REJECTED)

      get edit_admin_match_route_match_decision_step_path(route, step)

      expect(response.body).to include('Some Step')
      expect(response.body).to match(/<option selected="selected" value="#{MatchDecisionReasons::Base::CLIENT_REJECTED}">Client Rejected<\/option>/)
    end
  end

  describe 'PATCH update' do
    let(:reason) { create(:match_decision_reason, name: 'Reason A') }

    it 'updates default_referral_result' do
      patch admin_match_route_match_decision_step_path(route, step), params: {
        match_decision_step: { default_referral_result: MatchDecisionReasons::Base::PROVIDER_REJECTED },
      }

      expect(step.reload.default_referral_result).to eq(MatchDecisionReasons::Base::PROVIDER_REJECTED)
    end

    it 'creates step-level decline assignments scoped to this decision_type only' do
      patch admin_match_route_match_decision_step_path(route, step), params: {
        assignments: { decline: { reason.id.to_s => { selected: '1', position: '0', requires_explanation: '0' } } },
      }

      step_level = MatchDecisionReasonAssignment.where(route: route, decision_type: step.decision_type, kind: 'decline')
      route_level = MatchDecisionReasonAssignment.where(route: route, decision_type: '', kind: 'decline')
      expect(step_level.map(&:match_decision_reason_id)).to eq([reason.id])
      expect(route_level).to be_empty
    end
  end
end
