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
  let(:step) { create(:match_decision_step, route: route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff') }
  let(:step_without_declines) { create(:match_decision_step, route: route, decision_type: 'MatchDecisions::ConfirmMatchSuccessDndStaff') }
  let(:multi_actor_step) { create(:match_decision_step, route: route, decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin') }

  before do
    admin.roles << admin_role
    sign_in admin
  end

  describe 'GET edit' do
    it 'shows a human-readable step title and its current default_referral_result selected' do
      step.update!(default_referral_result: MatchDecisionReasons::Base::CLIENT_REJECTED)

      get edit_admin_match_route_match_decision_step_path(route, step)

      expect(response.body).to include('DND Initial Review')
      expect(response.body).to match(/<option selected="selected" value="#{MatchDecisionReasons::Base::CLIENT_REJECTED}">Client Rejected<\/option>/)
    end

    it 'shows a Decline Reasons card when the step supports declines' do
      get edit_admin_match_route_match_decision_step_path(route, step)

      expect(response.body).to include('Decline Reasons')
    end

    it 'omits the Decline Reasons card entirely when the step does not support declines' do
      get edit_admin_match_route_match_decision_step_path(route, step_without_declines)

      expect(response.body).not_to include('Decline Reasons')
      expect(response.body).to include('Cancel Reasons')
    end

    it "shows an Audience select with the route's own visible contact type labels and the assignment's current audience selected, for a step that supports multiple actors" do
      reason = create(:match_decision_reason, name: 'Reason A')
      create(:match_decision_reason_assignment, route: route, decision_type: multi_actor_step.decision_type, kind: 'decline', match_decision_reason: reason, audience: 'shelter_agency_contacts')

      get edit_admin_match_route_match_decision_step_path(route, multi_actor_step)

      expect(response.body).to include('Audience')
      expect(response.body).to include('Shelter Agency')
      expect(response.body).to match(/<option selected="selected" value="shelter_agency_contacts">Shelter Agency<\/option>/)
    end

    it 'omits the Audience column entirely for a step that does not support multiple actors' do
      get edit_admin_match_route_match_decision_step_path(route, step)

      expect(response.body).not_to include('Audience')
    end

    it 'shows the Audience column on the Decline table but not the Cancel table, even for a step that supports multiple actors' do
      get edit_admin_match_route_match_decision_step_path(route, multi_actor_step)

      doc = Nokogiri::HTML(response.body)
      cards = doc.css('.c-card').index_by { |card| card.at_css('h3')&.text }

      expect(cards['Decline Reasons'].text).to include('Audience')
      expect(cards['Cancel Reasons'].text).not_to include('Audience')
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
      other_step = create(:match_decision_step, route: route, decision_type: 'MatchDecisions::MatchRecommendationShelterAgency')

      patch admin_match_route_match_decision_step_path(route, step), params: {
        assignments: { decline: { reason.id.to_s => { selected: '1', position: '0', requires_explanation: '0' } } },
      }

      step_level = MatchDecisionReasonAssignment.where(route: route, decision_type: step.decision_type, kind: 'decline')
      other_step_level = MatchDecisionReasonAssignment.where(route: route, decision_type: other_step.decision_type, kind: 'decline')
      expect(step_level.map(&:match_decision_reason_id)).to eq([reason.id])
      expect(other_step_level).to be_empty
    end

    it 'persists an audience selection onto the assignment, for a step that supports multiple actors' do
      patch admin_match_route_match_decision_step_path(route, multi_actor_step), params: {
        assignments: { decline: { reason.id.to_s => { selected: '1', position: '0', audience: 'shelter_agency_contacts' } } },
      }

      assignment = MatchDecisionReasonAssignment.find_by(route: route, decision_type: multi_actor_step.decision_type, kind: 'decline', match_decision_reason: reason)
      expect(assignment.audience).to eq('shelter_agency_contacts')
    end

    it 'ignores decline assignment params for a step that does not support declines' do
      patch admin_match_route_match_decision_step_path(route, step_without_declines), params: {
        assignments: { decline: { reason.id.to_s => { selected: '1', position: '0' } } },
      }

      expect(MatchDecisionReasonAssignment.where(route: route, decision_type: step_without_declines.decision_type, kind: 'decline')).to be_empty
    end
  end
end
