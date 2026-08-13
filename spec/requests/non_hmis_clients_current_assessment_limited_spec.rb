###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NonHmisClients#current_assessment_limited', type: :request do
  let!(:agency) { create(:agency) }
  # can_view_all_covid_pathways lets find_match skip its match_id lookup, which is
  # incidental to this action's own rendering and would otherwise require a full
  # ClientOpportunityMatch fixture graph just to reach the view.
  let!(:viewer_role) { create(:role, name: 'covid_pathways_viewer_role', can_view_all_covid_pathways: true) }
  let!(:viewer) { create(:user, agency: agency, roles: [viewer_role]) }

  before do
    NonHmisClient.skip_build_assessment_if_missing = true
    sign_in viewer
  end

  # Both views are rendered read-only (disabled: true), the branch _common_tc_hat_questions.haml
  # and _common_pathways_version_three_questions.haml take when NOT editing. Regression coverage
  # for https://github.com/greenriver/boston-cas/pull/1151#pullrequestreview-4931571565: the fix in
  # non_hmis_assessments_spec.rb only exercised the editable (disabled: false) form.
  it 'renders a TC-HAT assessment description field for an identified client without raising NoMethodError on render_markdown' do
    create(:config, identified_client_assessment: 'IdentifiedTcHat')
    client = create(:identified_client, agency: agency, identified: true)
    assessment = create(:non_hmis_assessment, type: 'IdentifiedTcHat', non_hmis_client: client, agency: agency)

    get current_assessment_limited_identified_client_path(assessment.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Placed on prioritization list')
  end

  it 'renders the Pathways V3 preamble for a deidentified client without raising NoMethodError on render_markdown' do
    create(:config, deidentified_client_assessment: 'DeidentifiedPathwaysVersionThree')
    client = create(:deidentified_client, agency: agency, identified: false)
    assessment = create(:non_hmis_assessment, type: 'DeidentifiedPathwaysVersionThree', non_hmis_client: client, agency: agency)

    get current_assessment_limited_deidentified_client_path(assessment.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Veteran Agency Contact Details')
  end
end
