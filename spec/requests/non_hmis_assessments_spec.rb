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
        expect(response).to have_http_status(:not_found)
      end

      it 'denies creating an assessment for an identified client in another agency' do
        post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_other_agency.id), params: assessment_params
        expect(response).to have_http_status(:not_found)
        expect(NonHmisAssessment.count).to eq(0) # Ensure no assessment was created
      end

      it 'redirects to root for the new assessment page for a client in their own agency' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end

      it 'does not create an assessment for a client in their own agency' do
        expect do
          post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id), params: assessment_params
        end.not_to change(NonHmisAssessment, :count)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root for the assessment list of a client in their own agency' do
        get identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can enter identified clients' do
      let(:enterer) { create(:user, agency: user_agency, roles: [create(:role, name: 'enter_identified_test', can_enter_identified_clients: true)]) }

      before { sign_in enterer }

      it 'creates an assessment for a client in the user agency' do
        expect do
          post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id), params: assessment_params
        end.to change { identified_client_user_agency.non_hmis_assessments.count }.by(1)
      end

      it 'renders the assessment list for a client in the user agency' do
        get identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to have_http_status(:ok)
      end

      it 'redirects to root for the new assessment page for a de-identified client in the user agency' do
        get new_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can only edit all clients' do
      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'edit_all_clients_only_test', can_edit_all_clients: true)])
      end

      it 'redirects to root for the new assessment page' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end

      it 'does not create an assessment' do
        expect do
          post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id), params: assessment_params
        end.not_to change(NonHmisAssessment, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can manage identified clients but not all of them' do
      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'manage_identified_test', can_manage_identified_clients: true)])
      end

      it 'renders the assessment list for an identified client in the user agency' do
        get identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Client currently has no assessments')
      end
    end

    context 'when user can only enter de-identified clients' do
      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'enter_deidentified_only_test', can_enter_deidentified_clients: true)])
      end

      it 'redirects to root for the assessment list of an identified client in the user agency' do
        get identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can only view COVID pathways data' do
      let!(:covid_assessment) do
        create(:non_hmis_assessment, type: 'IdentifiedCovidPathwaysAssessment', non_hmis_client: identified_client_other_agency, agency: other_agency)
      end
      let!(:non_covid_assessment) do
        create(:non_hmis_assessment, type: 'IdentifiedClientAssessment', non_hmis_client: identified_client_other_agency, agency: other_agency)
      end

      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'covid_viewer_test', can_view_all_covid_pathways: true)])
      end

      it 'lists only the COVID Pathways assessments of a client in another agency' do
        get identified_client_non_hmis_assessments_path(identified_client_id: identified_client_other_agency.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(current_assessment_limited_identified_client_path(covid_assessment.id))
        expect(response.body).not_to include(current_assessment_limited_identified_client_path(non_covid_assessment.id))
      end

      it 'redirects to root for the new assessment page' do
        get new_identified_client_non_hmis_assessment_path(identified_client_id: identified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
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

      it 'redirects to root for the new assessment page for a client in their own agency' do
        get new_deidentified_client_non_hmis_assessment_path(deidentified_client_id: deidentified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end

      it 'does not create an assessment for a client in their own agency' do
        expect do
          post deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_user_agency.id), params: assessment_params
        end.not_to change(NonHmisAssessment, :count)
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root for the assessment list of a client in their own agency' do
        get deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can enter deidentified clients' do
      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'enter_deidentified_test', can_enter_deidentified_clients: true)])
      end

      it 'creates an assessment for a client in the user agency' do
        expect do
          post deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_user_agency.id), params: assessment_params
        end.to change { deidentified_client_user_agency.non_hmis_assessments.count }.by(1)
      end
    end

    context 'when user can only enter identified clients' do
      before do
        sign_in create(:user, agency: user_agency, roles: [create(:role, name: 'enter_identified_only_test', can_enter_identified_clients: true)])
      end

      it 'redirects to root for the assessment list of a de-identified client in the user agency' do
        get deidentified_client_non_hmis_assessments_path(deidentified_client_id: deidentified_client_user_agency.id)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'updating an assessment' do
    let(:enterer) { create(:user, agency: user_agency, roles: [create(:role, name: 'update_enter_identified_test', can_enter_identified_clients: true)]) }
    let!(:assessment) do
      IdentifiedPathwaysVersionFour.create!(
        entry_date: Date.current,
        assessment_type: 'pathways_2024',
        non_hmis_client: identified_client_user_agency,
        agency: user_agency,
        hud_assessment_location: 1,
        hud_assessment_type: 1,
        setting: 'Emergency Shelter',
        household_size: 1,
        denial_required: [''].to_s,
        service_need_indicators: '',
      )
    end

    before { sign_in enterer }

    it 'keeps the assessment type when an update sends a different one' do
      patch identified_client_non_hmis_assessment_path(identified_client_id: identified_client_user_agency.id, id: assessment.id),
            params: { identified_pathways_version_four: { assessment_type: 'transfer_assessment', setting: 'Unsheltered' } }

      expect(response).to redirect_to(identified_client_path(identified_client_user_agency))
      assessment.reload
      expect(assessment.setting).to eq('Unsheltered')
      expect(assessment.assessment_type).to eq('pathways_2024')
    end
  end

  describe 'creating an assessment that requires a type choice' do
    let(:enterer) { create(:user, agency: user_agency, roles: [create(:role, name: 'create_typed_identified_test', can_enter_identified_clients: true)]) }
    let(:client) { identified_client_user_agency }
    let(:body_params) do
      {
        entry_date: Date.current,
        hud_assessment_location: 1,
        hud_assessment_type: 1,
        setting: 'Emergency Shelter',
        household_size: 1,
        denial_required: [''],
        service_need_indicators: [''],
      }
    end

    before do
      Config.first_or_create.update!(identified_client_assessment: 'IdentifiedPathwaysVersionFour')
      sign_in enterer
    end

    def post_assessment(query_type:, body: {})
      post identified_client_non_hmis_assessments_path(identified_client_id: client.id, assessment_type: query_type),
           params: { identified_pathways_version_four: body_params.merge(body) }
    end

    it 'saves the assessment type chosen in the query string' do
      expect { post_assessment(query_type: 'family_pathways_2024') }.to change { client.non_hmis_assessments.count }.by(1)

      expect(client.non_hmis_assessments.last.assessment_type).to eq('family_pathways_2024')
    end

    it 'redirects to the type choice screen and saves nothing for an unknown type' do
      expect { post_assessment(query_type: 'zzz') }.not_to(change { NonHmisAssessment.count })

      expect(response).to redirect_to(new_identified_client_non_hmis_assessment_path(identified_client_id: client.id))
    end

    it 'redirects to the type choice screen and saves nothing when no type is given' do
      expect { post_assessment(query_type: nil) }.not_to(change { NonHmisAssessment.count })

      expect(response).to redirect_to(new_identified_client_non_hmis_assessment_path(identified_client_id: client.id))
    end

    it 'ignores an assessment type sent in the assessment body' do
      post_assessment(query_type: 'pathways_2024', body: { assessment_type: 'transfer_assessment' })

      expect(client.non_hmis_assessments.last.assessment_type).to eq('pathways_2024')
    end
  end

  describe 'creating an assessment that has no type choice' do
    let(:enterer) { create(:user, agency: user_agency, roles: [create(:role, name: 'create_untyped_identified_test', can_enter_identified_clients: true)]) }

    before { sign_in enterer }

    it 'ignores an assessment type sent in the assessment body' do
      post identified_client_non_hmis_assessments_path(identified_client_id: identified_client_user_agency.id),
           params: { identified_client_assessment: { assessment_type: 'zzz' } }

      expect(response).to have_http_status(:redirect)
      expect(identified_client_user_agency.non_hmis_assessments.last.assessment_type).to be_nil
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
