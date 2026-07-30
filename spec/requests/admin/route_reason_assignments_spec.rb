###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::RouteReasonAssignments', type: :request do
  let!(:admin_role) { create(:admin_role, can_manage_config: true) }
  let!(:admin) { create(:user) }
  let(:route) { create(:default_route) }

  before do
    admin.roles << admin_role
    sign_in admin
  end

  describe 'GET edit' do
    it 'lists active catalog reasons for both decline and cancel tables' do
      create(:match_decision_reason, name: 'Client Deceased')

      get edit_admin_match_route_route_reason_assignment_path(route)

      expect(response.body).to include('Client Deceased')
    end

    it 'excludes inactive reasons' do
      create(:match_decision_reason, name: 'Retired Reason', active: false)

      get edit_admin_match_route_route_reason_assignment_path(route)

      expect(response.body).not_to include('Retired Reason')
    end
  end

  describe 'PATCH update' do
    let(:reason_a) { create(:match_decision_reason, name: 'Reason A') }
    let(:reason_b) { create(:match_decision_reason, name: 'Reason B') }

    it 'creates route-level decline assignments for checked reasons only' do
      patch admin_match_route_route_reason_assignment_path(route), params: {
        assignments: {
          decline: {
            reason_a.id.to_s => { selected: '1', position: '0', requires_explanation: '1' },
            reason_b.id.to_s => { selected: '0', position: '1', requires_explanation: '0' },
          },
        },
      }

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: '', kind: 'decline')
      expect(assignments.map(&:match_decision_reason_id)).to eq([reason_a.id])
      expect(assignments.first.requires_explanation).to eq(true)
    end

    it 'removes an assignment that gets unchecked on a subsequent update' do
      create(:match_decision_reason_assignment, route: route, decision_type: '', kind: 'decline', match_decision_reason: reason_a)

      patch admin_match_route_route_reason_assignment_path(route), params: {
        assignments: { decline: { reason_a.id.to_s => { selected: '0' } } },
      }

      expect(MatchDecisionReasonAssignment.where(route: route, decision_type: '', kind: 'decline')).to be_empty
    end

    it 'keeps decline and cancel assignments independent' do
      patch admin_match_route_route_reason_assignment_path(route), params: {
        assignments: {
          decline: { reason_a.id.to_s => { selected: '1', position: '0' } },
          cancel: { reason_b.id.to_s => { selected: '1', position: '0' } },
        },
      }

      expect(MatchDecisionReasonAssignment.where(route: route, decision_type: '', kind: 'decline').map(&:match_decision_reason_id)).to eq([reason_a.id])
      expect(MatchDecisionReasonAssignment.where(route: route, decision_type: '', kind: 'cancel').map(&:match_decision_reason_id)).to eq([reason_b.id])
    end
  end
end
