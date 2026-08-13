###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NonHmisAssessments', type: :request do
  let!(:user_agency) { create(:agency, name: 'User Agency') }
  let!(:other_agency) { create(:agency, name: 'Other Agency') }

  # Roles
  let!(:identified_manager_role) { create(:role, name: 'identified_manager_assessment_test', can_manage_all_identified_clients: true) }
  let!(:deidentified_manager_role) { create(:role, name: 'deidentified_manager_assessment_test', can_manage_all_deidentified_clients: true) }
  let!(:basic_role) { create(:role, name: 'basic_user_assessment_test_role') }

  # Users
  let!(:identified_manager_user) { create(:user, agency: user_agency, roles: [identified_manager_role]) }
  let!(:deidentified_manager_user) { create(:user, agency: user_agency, roles: [deidentified_manager_role]) }
  let!(:basic_user) { create(:user, agency: user_agency, roles: [basic_role]) }

  # Clients in Other Agency
  # Ensure your factories set the 'identified' attribute correctly as per the .identified and .deidentified scopes used in the controller.
  let!(:identified_client_other_agency) { create(:identified_client, agency: other_agency, identified: true) }
  let!(:deidentified_client_other_agency) { create(:deidentified_client, agency: other_agency, identified: false) }

  # Client in User's own agency (for basic user tests)
  let!(:identified_client_user_agency) { create(:identified_client, agency: user_agency, identified: true) }
  let!(:deidentified_client_user_agency) { create(:deidentified_client, agency: user_agency, identified: false) }

  before do
    # this flag prevents duplicate assessments are created due to after_initialize hooks
    NonHmisClient.skip_build_assessment_if_missing = true
  end

  describe 'Identified Clients Assessments' do
    let(:assessment_params) do
      {
        identified_client_assessment: attributes_for(:non_hmis_assessment, agency_id: user_agency.id, type: 'DeidentifiedCovidPathwaysAssessment'),
      }
    end

    context 'when user has can_manage_all_identified_clients permission' do
      before { sign_in identified_manager_user }

      it 'allows access to the new assessment page for an identified client in another agency' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_other_agency.id)
        expect(response).to have_http_status(:ok)
      end

      it 'allows creating an assessment for an identified client in another agency' do
        expect do
          post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_other_agency.id), params: assessment_params
        end.to change(NonHmisAssessment, :count).by(1)
        expect(response).to have_http_status(:redirect)
        assessment = NonHmisAssessment.last
        expect(assessment.non_hmis_client_id).to eq(identified_client_other_agency.id)
        expect(assessment.agency_id).to eq(user_agency.id)
      end
    end

    context 'when user is basic and lacks can_manage_all_identified_clients permission' do
      before { sign_in basic_user }

      it 'denies access to the new assessment page for an identified client in another agency' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_other_agency.id)
      end

      it 'denies creating an assessment for an identified client in another agency' do
        post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_other_agency.id), params: assessment_params
        expect(response).to have_http_status(:not_found)
        expect(NonHmisAssessment.count).to eq(0) # Ensure no assessment was created
      end

      it 'allows access to the new assessment page for an identified client in their own agency' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to have_http_status(:ok)
      end

      it 'allows creating an assessment for an identified client in their own agency' do
        expect do
          post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id), params: assessment_params
        end.to change(NonHmisAssessment, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'Deidentified Clients Assessments' do
    let(:assessment_params) do
      {
        deidentified_client_assessment: attributes_for(:non_hmis_assessment, agency_id: user_agency.id, type: 'DeidentifiedCovidPathwaysAssessment'),
      }
    end
    context 'when user has can_manage_all_deidentified_clients permission' do
      before { sign_in deidentified_manager_user }

      it 'allows access to the new assessment page for a deidentified client in another agency' do
        get new_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_other_agency.id)
        expect(response).to have_http_status(:ok)
      end

      it 'allows creating an assessment for a deidentified client in another agency' do
        expect do
          post deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_other_agency.id), params: assessment_params
        end.to change(NonHmisAssessment, :count).by(1)
        expect(response).to have_http_status(:redirect)
        assessment = NonHmisAssessment.last
        expect(assessment.non_hmis_client_id).to eq(deidentified_client_other_agency.id)
        expect(assessment.agency_id).to eq(user_agency.id)
      end
    end

    context 'when user is basic and lacks can_manage_all_deidentified_clients permission' do
      before { sign_in basic_user }

      it 'denies access to the new assessment page for a deidentified client in another agency' do
        get new_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_other_agency.id)
        expect(response).to have_http_status(:not_found)
      end

      it 'denies creating an assessment for a deidentified client in another agency' do
        post deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_other_agency.id), params: assessment_params
        expect(response).to have_http_status(:not_found)
        expect(NonHmisAssessment.count).to eq(0)
      end

      it 'allows access to the new assessment page for a deidentified client in their own agency' do
        get new_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_user_agency.id)
        expect(response).to have_http_status(:ok)
      end

      it 'allows creating an assessment for a deidentified client in their own agency' do
        expect do
          post deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_user_agency.id), params: assessment_params
        end.to change(NonHmisAssessment, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'editing a TC-HAT assessment' do
    # TC-HAT form fields carry a Markdown `description:` (see TcHatCalculations#form_fields),
    # rendered via non_hmis_clients/assessments/_common_description_display, which calls the
    # MarkdownHelper#render_markdown helper. include_all_helpers is off (config/application.rb),
    # so a controller only gets render_markdown if it explicitly includes MarkdownHelper.
    let!(:tc_hat_editor_role) { create(:role, name: 'tc_hat_editor_role', can_manage_deidentified_clients: true) }
    let!(:tc_hat_editor_user) { create(:user, agency: user_agency, roles: [tc_hat_editor_role]) }
    let!(:assessment) do
      create(:non_hmis_assessment, type: 'DeidentifiedTcHat', non_hmis_client: deidentified_client_user_agency, agency: user_agency)
    end

    before { sign_in tc_hat_editor_user }

    it 'renders the description Markdown for a field instead of raising NoMethodError on render_markdown' do
      get edit_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_user_agency.id, id: assessment.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Placed on prioritization list')
    end
  end
end
