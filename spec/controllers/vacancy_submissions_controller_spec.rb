###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmissionsController, type: :controller do
  let(:user)       { create(:user) }
  let(:admin_role) { create(:admin_role) }

  before do
    authenticate(user)
    user.roles << admin_role
  end

  describe 'GET #index' do
    let!(:submission) { create(:vacancy_submission) }

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns @vacancy_submissions' do
      get :index
      expect(assigns(:vacancy_submissions)).to include(submission)
    end

    it 'filters by status=active' do
      active = create(:vacancy_submission, :active)
      get :index, params: { status: 'active' }
      expect(assigns(:vacancy_submissions)).to contain_exactly(active)
    end

    it 'returns 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'assigns a new VacancySubmission' do
      get :new
      expect(assigns(:vacancy_submission)).to be_a_new(VacancySubmission)
    end

    it 'assigns @programs' do
      create(:program)
      get :new
      expect(assigns(:programs)).to be_present
    end
  end

  describe 'POST #create' do
    let(:program)     { create(:program) }
    let(:building)    { create(:building) }
    let(:sub_program) { create(:sub_program, program: program, program_type: 'Project-Based', building: building) }

    let(:valid_params) do
      {
        vacancy_submission: {
          program_id: program.id,
          sub_program_id: sub_program.id,
          units: {
            '0' => {
              building_id: building.id,
              unit_number: '1A',
            },
          },
        },
      }
    end

    it 'creates a new VacancySubmission' do
      expect do
        post :create, params: valid_params
      end.to change(VacancySubmission, :count).by(1)
    end

    it 'sets status to awaiting_approval' do
      post :create, params: valid_params
      expect(VacancySubmission.last.status).to eq('awaiting_approval')
    end

    it 'derives is_voucher as false for Project-Based sub-program' do
      post :create, params: valid_params
      expect(VacancySubmission.last.draft_data['is_voucher']).to be false
    end

    it 'sets user_id to current user' do
      post :create, params: valid_params
      expect(VacancySubmission.last.user).to eq(user)
    end

    it 'redirects to index on success' do
      post :create, params: valid_params
      expect(response).to redirect_to(vacancy_submissions_path)
    end

    context 'with a Tenant-Based sub-program (voucher)' do
      let(:voucher_sp) { create(:sub_program, program: program, program_type: 'Tenant-Based') }

      it 'sets is_voucher to true and does not require address' do
        post :create, params: {
          vacancy_submission: {
            program_id: program.id,
            sub_program_id: voucher_sp.id,
            units: { '0' => { name: 'Voucher #1' } },
          },
        }
        expect(VacancySubmission.last.draft_data['is_voucher']).to be true
      end
    end

    context 'with missing required fields' do
      it 'does not create a submission and re-renders new' do
        expect do
          post :create, params: { vacancy_submission: { program_id: program.id } }
        end.not_to change(VacancySubmission, :count)
        expect(response).to render_template(:new)
      end
    end

    context 'with a variable-requiring rule but a blank variable' do
      let!(:variable_rule) { create(:bedroom_exact) }

      it 'does not create a submission and re-renders new' do
        expect do
          post :create, params: {
            vacancy_submission: {
              program_id: program.id,
              sub_program_id: sub_program.id,
              units: {
                '0' => {
                  building_id: building.id,
                  unit_number: '1A',
                  requirements_attributes: {
                    '0' => { rule_id: variable_rule.id.to_s, positive: 'true', variable: '' },
                  },
                },
              },
            },
          }
        end.not_to change(VacancySubmission, :count)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #sub_program_section (vacancy section)' do
    render_views

    let(:program)  { create(:program) }
    let(:building) { create(:building, name: 'Maple Court', address: '10 Maple St', city: 'Boston', state: 'MA', zip_code: '02118') }

    def get_vacancy_section(sub_program)
      get :sub_program_section, params: { section: 'vacancy', sub_program_id: sub_program.id }
    end

    it 'renders a building select2 dropdown listing existing buildings by name and street' do
      sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: building)
      get_vacancy_section(sub_program)
      expect(response.body).to include('vacancy_submission[units][0][building_id]')
      expect(response.body).to include('select2')
      expect(response.body).to include('Maple Court (10 Maple St)')
    end

    it 'pre-selects the sub-program building by default' do
      sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: building)
      get_vacancy_section(sub_program)
      expect(response.body).to match(/value="#{building.id}"[^>]*selected|selected[^>]*value="#{building.id}"/)
    end

    it 'shows the confidential warning when the sub-program is confidential' do
      sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: building, confidential: true)
      get_vacancy_section(sub_program)
      expect(response.body).to include('This program is confidential, do not enter a real address as the unit number')
    end

    it 'omits the confidential warning when the sub-program is not confidential' do
      sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: building, confidential: false)
      get_vacancy_section(sub_program)
      expect(response.body).not_to include('This program is confidential')
    end
  end

  describe 'GET #show' do
    let!(:submission) { create(:vacancy_submission) }

    it 'renders the show template for a reviewer' do
      get :show, params: { id: submission.id }
      expect(response).to render_template(:show)
    end

    it 'assigns @submission' do
      get :show, params: { id: submission.id }
      expect(assigns(:submission)).to eq(submission)
    end

    it 'assigns @notes in chronological order' do
      note1 = create(:vacancy_submission_note, vacancy_submission: submission, created_at: 1.hour.ago)
      note2 = create(:vacancy_submission_note, vacancy_submission: submission, created_at: 1.minute.ago)
      get :show, params: { id: submission.id }
      expect(assigns(:notes).to_a).to eq([note1, note2])
    end

    context 'when the submission is active and has a linked unit' do
      render_views

      let(:unit) { create(:unit, building: create(:building)) }
      let(:active_submission) { create(:vacancy_submission, :active) }

      before do
        active_submission.units = [{ 'building_id' => unit.building_id, 'unit_number' => '1A', 'unit_id' => unit.id, 'voucher_id' => 999 }]
        active_submission.save!
      end

      it 'shows an Edit Unit link when the user can edit units' do
        get :show, params: { id: active_submission.id }
        expect(response.body).to include(edit_unit_path(unit))
      end

      it 'does not show an Edit Unit link when the user cannot edit units' do
        user.roles = [create(:role, name: 'reviewer_only', can_review_vacancies: true)]
        get :show, params: { id: active_submission.id }
        expect(response.body).not_to include(edit_unit_path(unit))
      end
    end

    context 'when user lacks both vacancy permissions' do
      let(:no_vacancy_role) { create(:role, name: 'no_vacancy') }

      before do
        user.roles = [no_vacancy_role]
      end

      it 'redirects with not authorized' do
        get :show, params: { id: submission.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #edit' do
    let!(:submission) { create(:vacancy_submission, :changes_requested) }

    it 'renders the edit template' do
      get :edit, params: { id: submission.id }
      expect(response).to render_template(:edit)
    end

    it 'assigns @submission' do
      get :edit, params: { id: submission.id }
      expect(assigns(:submission)).to eq(submission)
    end

    it 'redirects with alert when submission is not resubmittable' do
      submission.update!(status: 'awaiting_approval')
      get :edit, params: { id: submission.id }
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
    end
  end

  describe 'PATCH #update' do
    let(:program)      { create(:program) }
    let(:building)     { create(:building) }
    let(:new_building) { create(:building) }
    let(:sub_program)  { create(:sub_program, program: program, program_type: 'Project-Based', building: building) }
    let!(:submission)  { create(:vacancy_submission, :changes_requested, the_program: program, the_sub_program: sub_program) }

    let(:update_params) do
      {
        id: submission.id,
        vacancy_submission: {
          program_id: program.id,
          sub_program_id: sub_program.id,
          units: {
            '0' => {
              building_id: new_building.id,
              unit_number: '2B',
            },
          },
        },
      }
    end

    it 'updates the submission draft_data' do
      patch :update, params: update_params
      expect(submission.reload.draft_data['units'][0]['building_id'].to_i).to eq(new_building.id)
    end

    it 'creates a note recording the address change' do
      expect do
        patch :update, params: update_params
      end.to change(VacancySubmissionNote, :count).by(1)
      expect(VacancySubmissionNote.last.body).to include('Vacancy')
    end

    it 'redirects to the show page on success' do
      patch :update, params: update_params
      expect(response).to redirect_to(vacancy_submission_path(submission))
    end

    it 'redirects with alert when submission is not resubmittable' do
      submission.update!(status: 'awaiting_approval')
      patch :update, params: update_params
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
    end

    it 're-renders edit when sub_program is missing' do
      patch :update, params: {
        id: submission.id,
        vacancy_submission: { program_id: program.id },
      }
      expect(response).to render_template(:edit)
    end
  end

  describe 'POST #approve' do
    let!(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

    it 'transitions status to active' do
      expect do
        post :approve, params: { id: submission.id }
      end.to change { submission.reload.status }.from('awaiting_approval').to('active')
    end

    it 'creates a status_change note' do
      expect do
        post :approve, params: { id: submission.id }
      end.to change(VacancySubmissionNote, :count).by(1)
      expect(VacancySubmissionNote.last.note_type).to eq('status_change')
    end

    it 'redirects to the show page' do
      post :approve, params: { id: submission.id }
      expect(response).to redirect_to(vacancy_submission_path(submission))
    end

    it 'redirects with alert when submission is already active' do
      submission.update!(status: 'active')
      post :approve, params: { id: submission.id }
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
    end

    context 'when user can only submit (not review)' do
      let(:submit_only_role) { create(:role, name: 'submit_only', can_add_vacancies: true) }

      before { user.roles = [submit_only_role] }

      it 'redirects with not authorized' do
        post :approve, params: { id: submission.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when approval fails' do
      it 'surfaces a RecordInvalid as a flash alert and leaves the status unchanged' do
        allow_any_instance_of(VacancySubmission).to receive(:approve!).
          and_raise(ActiveRecord::RecordInvalid.new(submission))

        post :approve, params: { id: submission.id }

        expect(response).to redirect_to(vacancy_submission_path(submission))
        expect(flash[:alert]).to be_present
        expect(submission.reload.status).to eq('awaiting_approval')
      end

      it 'rescues an unexpected error and surfaces a generic alert instead of raising' do
        allow_any_instance_of(VacancySubmission).to receive(:approve!).
          and_raise(StandardError.new('boom'))

        expect { post :approve, params: { id: submission.id } }.not_to raise_error
        expect(response).to redirect_to(vacancy_submission_path(submission))
        expect(flash[:alert]).to be_present
        expect(submission.reload.status).to eq('awaiting_approval')
      end
    end
  end

  describe 'POST #return_submission' do
    let!(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

    it 'transitions status to return_changes_requested' do
      expect do
        post :return_submission, params: { id: submission.id, body: 'Please fix the address.' }
      end.to change { submission.reload.status }.to('return_changes_requested')
    end

    it 'creates a reviewer_note and a status_change note' do
      expect do
        post :return_submission, params: { id: submission.id, body: 'Fix it.' }
      end.to change(VacancySubmissionNote, :count).by(2)
      types = VacancySubmissionNote.last(2).map(&:note_type)
      expect(types).to include('reviewer_note', 'status_change')
    end

    it 'redirects with alert when body is blank' do
      post :return_submission, params: { id: submission.id, body: '' }
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
      expect(submission.reload.status).to eq('awaiting_approval')
    end

    it 'redirects with alert when submission is active' do
      submission.update!(status: 'active')
      post :return_submission, params: { id: submission.id, body: 'Fix it.' }
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
    end

    context 'when user can only submit (not review)' do
      let(:submit_only_role) { create(:role, name: 'submit_only', can_add_vacancies: true) }

      before { user.roles = [submit_only_role] }

      it 'redirects with not authorized' do
        post :return_submission, params: { id: submission.id, body: 'Fix it.' }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #resubmit' do
    let!(:submission) { create(:vacancy_submission, :changes_requested) }

    it 'transitions status to awaiting_approval' do
      expect do
        post :resubmit, params: { id: submission.id }
      end.to change { submission.reload.status }.to('awaiting_approval')
    end

    it 'creates a status_change note' do
      expect do
        post :resubmit, params: { id: submission.id }
      end.to change(VacancySubmissionNote, :count).by(1)
    end

    it 'redirects to the show page' do
      post :resubmit, params: { id: submission.id }
      expect(response).to redirect_to(vacancy_submission_path(submission))
    end

    it 'redirects with alert when not resubmittable' do
      submission.update!(status: 'awaiting_approval')
      post :resubmit, params: { id: submission.id }
      expect(response).to redirect_to(vacancy_submission_path(submission))
      expect(flash[:alert]).to be_present
    end

    context 'when user lacks can_add_vacancies' do
      let(:review_only_role) { create(:role, name: 'review_only', can_review_vacancies: true) }

      before { user.roles = [review_only_role] }

      it 'redirects with not authorized' do
        post :resubmit, params: { id: submission.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
