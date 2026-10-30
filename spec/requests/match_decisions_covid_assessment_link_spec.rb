###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MatchDecisions#show COVID assessment link', type: :request do
  let!(:admin_role) { create :admin_role }
  let!(:admin) { create(:user, roles: [admin_role]) }
  let!(:priority) { create :priority_vispdat_priority }
  let!(:route) { create :default_route, match_prioritization: priority }
  let!(:program) { create :program, match_route: route }
  let!(:sub_program) { create :sub_program, program: program }
  let!(:voucher) { create :voucher, sub_program: sub_program }
  let!(:opportunity) { create :opportunity, voucher: voucher }
  let!(:non_hmis_data_source) { create(:data_source, :deidentified) }
  let!(:non_hmis_client) { create(:identified_client, identified: true) }
  let!(:covid_assessment) { create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: non_hmis_client) }
  let!(:client) { create(:client) }
  let!(:match) { create :client_opportunity_match, match_route: route, opportunity: opportunity, client: client }

  before do
    NonHmisClient.skip_build_assessment_if_missing = true
    create(
      :project_client,
      data_source_id: non_hmis_data_source.id,
      id_in_data_source: non_hmis_client.id,
      client_id: client.id,
    )
    match.match_recommendation_dnd_staff_decision.update(status: 'pending')
  end

  it 'links to the client COVID assessment for a user who can see client info' do
    sign_in admin

    get match_decision_path(match, 'match_recommendation_dnd_staff')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(current_assessment_limited_identified_client_path(covid_assessment.id, match_id: match.id))
  end

  it 'omits the COVID assessment link for a user who cannot see client info' do
    approver_role = create(:role, name: 'match_approver_role', can_view_all_matches: true, can_approve_matches: true)
    approver = create(:user, roles: [approver_role])
    sign_in approver

    get match_decision_path(match, 'match_recommendation_dnd_staff')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(match_client_details_path(match))
    expect(response.body).not_to include(current_assessment_limited_identified_client_path(covid_assessment.id, match_id: match.id))
  end
end
