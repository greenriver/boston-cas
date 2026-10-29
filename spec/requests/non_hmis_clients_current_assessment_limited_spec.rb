###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NonHmisClients#current_assessment_limited', type: :request do
  let!(:agency) { create(:agency) }
  let!(:viewer_role) { create(:role, name: 'agency_client_entry_role', can_enter_identified_clients: true, can_enter_deidentified_clients: true) }
  let!(:viewer) { create(:user, agency: agency, roles: [viewer_role]) }

  before do
    NonHmisClient.skip_build_assessment_if_missing = true
    sign_in viewer
  end

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

  describe 'access' do
    let!(:non_hmis_data_source) { create(:data_source, :deidentified) }
    let!(:other_agency) { create(:agency) }
    let!(:other_client) { create(:identified_client, agency: other_agency, identified: true) }
    let!(:other_tc_hat) { create(:non_hmis_assessment, type: 'IdentifiedTcHat', non_hmis_client: other_client, agency: other_agency) }

    context 'with a user who can enter clients for their own agency' do
      before do
        create(:config, identified_client_assessment: 'IdentifiedTcHat')
      end

      it 'redirects for a client in another agency' do
        get current_assessment_limited_identified_client_path(other_tc_hat.id)

        expect(response).to redirect_to(root_path)
      end

      it 'renders for a client with no agency, matching the client show page' do
        unassigned_client = create(:identified_client, agency: nil, identified: true)
        tc_hat = create(:non_hmis_assessment, type: 'IdentifiedTcHat', non_hmis_client: unassigned_client)

        get current_assessment_limited_identified_client_path(tc_hat.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Placed on prioritization list')
      end
    end

    context 'with a user who can enter deidentified clients for their own agency' do
      before do
        create(:config, deidentified_client_assessment: 'DeidentifiedPathwaysVersionThree')
      end

      it 'redirects for a deidentified client in another agency' do
        other_deidentified = create(:deidentified_client, agency: other_agency, identified: false)
        pathways = create(:non_hmis_assessment, type: 'DeidentifiedPathwaysVersionThree', non_hmis_client: other_deidentified, agency: other_agency)

        get current_assessment_limited_deidentified_client_path(pathways.id)

        expect(response).to redirect_to(root_path)
      end
    end

    context 'with a user who can manage identified clients in all agencies' do
      let!(:manager_role) { create(:role, name: 'all_agency_manager_role', can_enter_identified_clients: true, can_manage_all_identified_clients: true) }
      let!(:manager) { create(:user, agency: agency, roles: [manager_role]) }

      before do
        create(:config, identified_client_assessment: 'IdentifiedTcHat')
        sign_in manager
      end

      it 'renders a non-COVID assessment for a client in another agency' do
        get current_assessment_limited_identified_client_path(other_tc_hat.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Placed on prioritization list')
      end
    end

    context 'with a user who can manage deidentified clients in all agencies' do
      let!(:manager_role) { create(:role, name: 'all_agency_deidentified_manager_role', can_enter_deidentified_clients: true, can_manage_all_deidentified_clients: true) }
      let!(:manager) { create(:user, agency: agency, roles: [manager_role]) }

      before do
        create(:config, deidentified_client_assessment: 'DeidentifiedPathwaysVersionThree')
        sign_in manager
      end

      it 'renders a non-COVID deidentified assessment for a client in another agency' do
        other_deidentified = create(:deidentified_client, agency: other_agency, identified: false)
        pathways = create(:non_hmis_assessment, type: 'DeidentifiedPathwaysVersionThree', non_hmis_client: other_deidentified, agency: other_agency)

        get current_assessment_limited_deidentified_client_path(pathways.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Veteran Agency Contact Details')
      end
    end

    context 'with a covid pathways viewer who cannot enter clients' do
      let!(:covid_viewer_role) { create(:role, name: 'covid_pathways_viewer_role', can_view_all_covid_pathways: true) }
      let!(:covid_viewer) { create(:user, agency: agency, roles: [covid_viewer_role]) }

      before do
        sign_in covid_viewer
      end

      it 'redirects for a non-COVID assessment of a client in the viewer agency' do
        create(:config, identified_client_assessment: 'IdentifiedTcHat')
        own_agency_client = create(:identified_client, agency: agency, identified: true)
        tc_hat = create(:non_hmis_assessment, type: 'IdentifiedTcHat', non_hmis_client: own_agency_client, agency: agency)

        get current_assessment_limited_identified_client_path(tc_hat.id)

        expect(response).to redirect_to(root_path)
      end

      it 'redirects for a non-COVID assessment of a client in another agency who has a COVID assessment' do
        create(:config, identified_client_assessment: 'IdentifiedTcHat')
        create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: other_client, agency: other_agency)

        get current_assessment_limited_identified_client_path(other_tc_hat.id)

        expect(response).to redirect_to(root_path)
      end

      it 'renders a COVID assessment for a client in another agency' do
        create(:config, identified_client_assessment: 'IdentifiedCovidPathwaysAssessment')
        covid = create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: other_client, agency: other_agency)

        get current_assessment_limited_identified_client_path(covid.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('List any working email addresses you use')
      end

      it 'renders a deidentified COVID assessment for a client in another agency' do
        create(:config, deidentified_client_assessment: 'DeidentifiedCovidPathwaysAssessment')
        other_deidentified = create(:deidentified_client, agency: other_agency, identified: false)
        covid = create(:non_hmis_assessment, type: 'DeidentifiedCovidPathwaysAssessment', non_hmis_client: other_deidentified, agency: other_agency)

        get current_assessment_limited_deidentified_client_path(covid.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('List any working email addresses you use')
      end
    end

    context 'with a user who has no client permissions' do
      let!(:plain_role) { create(:role, name: 'no_client_permissions_role') }
      let!(:plain_user) { create(:user, agency: other_agency, roles: [plain_role]) }
      let!(:cas_client) do
        create(:client).tap do |client|
          create(
            :project_client,
            data_source_id: non_hmis_data_source.id,
            id_in_data_source: other_client.id,
            client_id: client.id,
          )
        end
      end
      let!(:match) { create(:client_opportunity_match, client: cas_client) }
      let!(:other_covid) { create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: other_client, agency: other_agency) }

      before do
        sign_in plain_user
      end

      context 'when COVID assessments are configured' do
        before do
          create(:config, identified_client_assessment: 'IdentifiedCovidPathwaysAssessment')
        end

        it 'returns not found when the user is not a contact on the match' do
          get current_assessment_limited_identified_client_path(other_covid.id, match_id: match.id)

          expect(response).to have_http_status(:not_found)
        end

        it 'redirects when no match is given' do
          ClientOpportunityMatchContact.create!(match: match, contact: plain_user.contact, shelter_agency: true)

          get current_assessment_limited_identified_client_path(other_covid.id)

          expect(response).to redirect_to(root_path)
        end

        it 'redirects when the assessment client is not the match client' do
          unrelated_match = create(:client_opportunity_match, client: create(:client))
          ClientOpportunityMatchContact.create!(match: unrelated_match, contact: plain_user.contact, shelter_agency: true)

          get current_assessment_limited_identified_client_path(other_covid.id, match_id: unrelated_match.id)

          expect(response).to redirect_to(root_path)
        end

        it 'redirects when the match contact cannot see client info yet' do
          ClientOpportunityMatchContact.create!(match: match, contact: plain_user.contact)

          get current_assessment_limited_identified_client_path(other_covid.id, match_id: match.id)

          expect(response).to redirect_to(root_path)
        end

        it 'redirects for an assessment with no client when the match client has no non-HMIS client' do
          hmis_match = create(:client_opportunity_match, client: create(:client))
          ClientOpportunityMatchContact.create!(match: hmis_match, contact: plain_user.contact, shelter_agency: true)
          orphan = create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: other_client, agency: other_agency)
          orphan.update_column(:non_hmis_client_id, nil)

          get current_assessment_limited_identified_client_path(orphan.id, match_id: hmis_match.id)

          expect(response).to redirect_to(root_path)
        end

        it 'renders the match client COVID assessment for a shelter agency contact on the match' do
          ClientOpportunityMatchContact.create!(match: match, contact: plain_user.contact, shelter_agency: true)

          get current_assessment_limited_identified_client_path(other_covid.id, match_id: match.id)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('List any working email addresses you use')
        end
      end

      it 'redirects for a non-COVID assessment of the match client for a shelter agency contact on the match' do
        create(:config, identified_client_assessment: 'IdentifiedTcHat')
        ClientOpportunityMatchContact.create!(match: match, contact: plain_user.contact, shelter_agency: true)

        get current_assessment_limited_identified_client_path(other_tc_hat.id, match_id: match.id)

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
