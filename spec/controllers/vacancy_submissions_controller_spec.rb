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
    let(:sub_program) { create(:sub_program, program: program, program_type: 'Project-Based', building: create(:building)) }

    let(:valid_params) do
      {
        vacancy_submission: {
          program_id:               program.id,
          sub_program_id:           sub_program.id,
          unit_address_street:      '123 Main St',
          unit_address_unit_number: '1A',
          unit_address_city:        'Boston',
          unit_address_state:       'MA',
          unit_address_zip:         '02101',
        },
      }
    end

    it 'creates a new VacancySubmission' do
      expect {
        post :create, params: valid_params
      }.to change(VacancySubmission, :count).by(1)
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
          vacancy_submission: { program_id: program.id, sub_program_id: voucher_sp.id },
        }
        expect(VacancySubmission.last.draft_data['is_voucher']).to be true
      end
    end

    context 'with missing required fields' do
      it 'does not create a submission and re-renders new' do
        expect {
          post :create, params: { vacancy_submission: { program_id: program.id } }
        }.not_to change(VacancySubmission, :count)
        expect(response).to render_template(:new)
      end
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

  describe 'POST #approve' do
    let!(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

    it 'transitions status to active' do
      expect {
        post :approve, params: { id: submission.id }
      }.to change { submission.reload.status }.from('awaiting_approval').to('active')
    end

    it 'creates a status_change note' do
      expect {
        post :approve, params: { id: submission.id }
      }.to change(VacancySubmissionNote, :count).by(1)
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
  end

  describe 'POST #return_submission' do
    let!(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

    it 'transitions status to return_changes_requested' do
      expect {
        post :return_submission, params: { id: submission.id, body: 'Please fix the address.' }
      }.to change { submission.reload.status }.to('return_changes_requested')
    end

    it 'creates a reviewer_note and a status_change note' do
      expect {
        post :return_submission, params: { id: submission.id, body: 'Fix it.' }
      }.to change(VacancySubmissionNote, :count).by(2)
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
      expect {
        post :resubmit, params: { id: submission.id }
      }.to change { submission.reload.status }.to('awaiting_approval')
    end

    it 'creates a status_change note' do
      expect {
        post :resubmit, params: { id: submission.id }
      }.to change(VacancySubmissionNote, :count).by(1)
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
  end
end
