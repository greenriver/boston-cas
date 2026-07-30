###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::MatchRoutes', type: :request do
  let!(:admin_role) { create(:admin_role, can_manage_config: true) }
  let!(:admin) { create(:user) }
  let(:active_route) { MatchRoutes::Default.first }
  let(:inactive_route) { MatchRoutes::ProviderOnly.first }

  before do
    admin.roles << admin_role
    sign_in admin
    active_route.update!(active: true)
    inactive_route.update!(active: false)
  end

  describe 'GET index' do
    it 'assigns active routes separately from inactive routes' do
      get admin_match_routes_path

      expect(assigns(:active_routes)).to include(active_route)
      expect(assigns(:active_routes)).not_to include(inactive_route)
      expect(assigns(:inactive_routes)).to include(inactive_route)
      expect(assigns(:inactive_routes)).not_to include(active_route)
    end

    it 'shows every route across both groups' do
      get admin_match_routes_path

      expect(assigns(:active_routes).size + assigns(:inactive_routes).size).to eq(MatchRoutes::Base.count)
    end

    it 'renders both tab panes with an edit link for their routes' do
      get admin_match_routes_path

      expect(response.body).to include('Active Routes')
      expect(response.body).to include('Inactive Routes')
      expect(response.body).to include(edit_admin_match_route_path(active_route))
      expect(response.body).to include(edit_admin_match_route_path(inactive_route))
    end

    it 'shows the multiple-clients-per-match and one-match-per-client columns, and drops the tag column' do
      active_route.update!(allow_multiple_active_matches: true, should_prevent_multiple_matches_per_client: false)

      get admin_match_routes_path

      expect(response.body).to include('Multiple Clients per Match')
      expect(response.body).to include('One Match per Client')
      expect(response.body).not_to include('Tag')
    end
  end

  describe 'GET edit' do
    it "shows the route's steps with active decline and cancel reason counts, and no separate customize link" do
      step = create(:match_decision_step, route: active_route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff')
      reason_a = create(:match_decision_reason, name: 'Reason A')
      reason_b = create(:match_decision_reason, name: 'Reason B')
      create(:match_decision_reason_assignment, route: active_route, decision_type: step.decision_type, kind: 'decline', match_decision_reason: reason_a)
      create(:match_decision_reason_assignment, route: active_route, decision_type: step.decision_type, kind: 'decline', match_decision_reason: reason_b)
      create(:match_decision_reason_assignment, route: active_route, decision_type: step.decision_type, kind: 'cancel', match_decision_reason: reason_a)

      get edit_admin_match_route_path(active_route)

      doc = Nokogiri::HTML(response.body)
      row = doc.css('table').to_a.flat_map { |t| t.css('tbody tr') }.find { |r| r.text.include?('DND Initial Review') }

      expect(row.css('td')[0].css('a').first['href']).to eq(edit_admin_match_route_match_decision_step_path(active_route, step))
      expect(row.css('td')[1].text.strip).to eq('2')
      expect(row.css('td')[2].text.strip).to eq('1')
      expect(response.body).not_to include('Customize this step')
    end

    it 'shows N/A for the decline column when a step does not support declines' do
      create(:match_decision_step, route: active_route, decision_type: 'MatchDecisions::ConfirmMatchSuccessDndStaff')

      get edit_admin_match_route_path(active_route)

      doc = Nokogiri::HTML(response.body)
      row = doc.css('table').to_a.flat_map { |t| t.css('tbody tr') }.find { |r| r.text.include?('Confirm Match Success') }

      expect(row.css('td')[1].text.strip).to eq('N/A')
    end
  end
end
