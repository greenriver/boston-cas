# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ClosedMatches Search', type: :request do
  # Ensure routes exist before running tests
  MatchRoutes::Base.ensure_all
  MatchPrioritization::Base.ensure_all

  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }
  let!(:program) { create(:program) }
  let!(:client1) { create(:client) }
  let!(:client2) { create(:client) }
  let!(:voucher1) { create(:voucher, sub_program: create(:sub_program, program: program)) }
  let!(:voucher2) { create(:voucher, sub_program: create(:sub_program, program: program)) }
  let!(:opportunity1) { create(:opportunity, voucher: voucher1) }
  let!(:opportunity2) { create(:opportunity, voucher: voucher2) }

  # Use existing route like the successful integration tests do
  let!(:match_route) { MatchRoutes::Default.first }
  let!(:closed_match_1) { create(:client_opportunity_match, client: client1, opportunity: opportunity1, match_route: match_route, closed: true, active: false) }
  let!(:closed_match_2) { create(:client_opportunity_match, client: client2, opportunity: opportunity2, match_route: match_route, closed: true, active: false) }

  before do
    admin.roles << admin_role
    sign_in admin

    # Ensure we have at least one active route with proper setup
    if MatchRoutes::Default.first.nil?
      # Create manually if ensure_all didn't work
      priority = MatchPrioritization::Base.first || create(:priority_days_homeless)
      MatchRoutes::Default.create!(active: true, match_prioritization: priority)
    end

    # Mock the instance variables that the view needs instead of stubbing the method
    allow_any_instance_of(MatchListBaseController).to receive(:set_available_steps) do |controller|
      controller.instance_variable_set(
        :@available_steps, [
          ['Match Recommendation DND Staff', 'MatchDecisions::MatchRecommendationDndStaff'],
          ['Match Recommendation HSA', 'MatchDecisions::MatchRecommendationHsa'],
          ['Confirm Match Success DND Staff', 'MatchDecisions::ConfirmMatchSuccessDndStaff'],
        ]
      )
    end
  end

  describe 'GET /closed_match_search_queries/:id' do
    it 'renders successfully and shows search results' do
      get closed_match_search_query_path(search_query)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Closed Matches')
    end

    it 'applies sort parameters' do
      get closed_match_search_query_path(search_query), params: { sort: 'last_decision', direction: 'asc' }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(opportunity1.voucher.sub_program.program.name)
      expect(response.body).to include(opportunity2.voucher.sub_program.program.name)
    end

    it 'accepts filter parameters' do
      get closed_match_search_query_path(search_query), params: {
        current_step: 'some_step',
        current_program: program.id,
        current_contact_type: 'hsp_contacts',
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Closed Matches')
      expect(response.body).to include(opportunity1.voucher.sub_program.program.name)
    end

    it 'does not create new search queries when only filter parameters change' do
      # This tests the important behavioral requirement from the controller spec
      expect do
        get closed_match_search_query_path(search_query), params: {
          current_route: 'MatchRoutes::Default',
          current_step: 'some_step',
        }
      end.not_to change(ClientSearchQuery, :count)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Closed Matches')
    end
  end
end
