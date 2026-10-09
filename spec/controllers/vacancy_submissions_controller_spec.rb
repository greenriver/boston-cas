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

    context 'rendering the program filter' do
      render_views

      it 'renders a select2 dropdown of programs and an Update Filter button, not a text search box' do
        create(:vacancy_submission, the_program: create(:program, name: 'Sunset Housing'))
        get :index

        expect(response.body).to include('select2')
        expect(response.body).to include('Sunset Housing')
        expect(response.body).to include('Update Filter')
        expect(response.body).not_to include('name="q"')
      end

      it 'excludes programs that have no vacancy submissions' do
        create(:vacancy_submission, the_program: create(:program, name: 'Sunset Housing'))
        create(:program, name: 'Never Submitted')

        get :index

        expect(response.body).to include('Sunset Housing')
        expect(response.body).not_to include('Never Submitted')
      end
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

    it 'notifies reviewers that a submission is awaiting review' do
      notifier = instance_double(VacancySubmissions::Notifier)
      allow(VacancySubmissions::Notifier).to receive(:new).and_return(notifier)
      expect(notifier).to receive(:notify_submitted!)

      post :create, params: valid_params
    end

    it 'does not notify when the submission is invalid' do
      expect(VacancySubmissions::Notifier).not_to receive(:new)

      post :create, params: { vacancy_submission: { program_id: program.id } }
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

    it 'omits the confidential warning when neither the program nor the sub-program is confidential' do
      sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: building, confidential: false)
      get_vacancy_section(sub_program)
      expect(response.body).not_to include('This program is confidential')
    end

    it 'shows the confidential warning when the program is confidential, even if the sub-program is not' do
      confidential_program = create(:program, confidential: true)
      sub_program = create(:sub_program, program: confidential_program, program_type: 'Project-Based', building: building, confidential: false)
      get_vacancy_section(sub_program)
      expect(response.body).to include('This program is confidential, do not enter a real address as the unit number')
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
      let(:active_submission) { create(:vacancy_submission, :active, user: create(:user, agency: user.agency)) }

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
      it 'surfaces a RecordInvalid as a flash alert and rolls back the status' do
        # Drive a real approval failure (no stubbing): a unit whose building can't
        # be found makes Approval raise RecordInvalid, so this exercises the real
        # rescue path and the reload genuinely proves the transaction rolled back.
        submission.units = [{ 'building_id' => 0, 'unit_number' => '1A' }]
        submission.save!

        post :approve, params: { id: submission.id }

        expect(response).to redirect_to(vacancy_submission_path(submission))
        expect(flash[:alert]).to be_present
        expect(submission.reload.status).to eq('awaiting_approval')
      end

      it 'rescues an unexpected error and surfaces a generic alert instead of raising' do
        # The real approval path converts its domain failures into RecordInvalid, so
        # an arbitrary non-domain error (e.g. an infrastructure fault) can only be
        # produced with a stub. This is the one branch that needs a seam; the deeper
        # fix would be making #approve! injectable so we needn't stub the class.
        allow(VacancySubmission).to receive(:visible_by).and_return(instance_double(ActiveRecord::Relation, find: submission))
        allow(submission).to receive(:approve!).and_raise(StandardError.new('boom'))

        expect { post :approve, params: { id: submission.id } }.not_to raise_error
        expect(response).to redirect_to(vacancy_submission_path(submission))
        expect(flash[:alert]).to be_present
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

    it 'notifies the submitter that changes were requested' do
      notifier = instance_double(VacancySubmissions::Notifier)
      allow(VacancySubmissions::Notifier).to receive(:new).and_return(notifier)
      expect(notifier).to receive(:notify_changes_requested!)

      post :return_submission, params: { id: submission.id, body: 'Fix it.' }
    end

    it 'does not notify when the body is blank' do
      expect(VacancySubmissions::Notifier).not_to receive(:new)

      post :return_submission, params: { id: submission.id, body: '' }
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

    it 'notifies reviewers that the submission was resubmitted' do
      notifier = instance_double(VacancySubmissions::Notifier)
      allow(VacancySubmissions::Notifier).to receive(:new).and_return(notifier)
      expect(notifier).to receive(:notify_resubmitted!)

      post :resubmit, params: { id: submission.id }
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

  describe 'agency scoping' do
    let(:assigned_role) do
      create(
        :role,
        name: 'assigned vacancy staff',
        can_view_opportunities: true,
        can_add_vacancies: true,
        can_review_vacancies: true,
        can_view_assigned_programs: true,
      )
    end
    let(:own_program) { create(:program, name: 'Own Agency Program') }
    let(:other_program) { create(:program, name: 'Other Agency Program') }
    let(:other_sub_program) { create(:sub_program, program: other_program, program_type: 'Project-Based', building: create(:building)) }
    let!(:own_submission) { create(:vacancy_submission, :changes_requested, the_program: own_program) }
    let!(:other_submission) { create(:vacancy_submission, :changes_requested, the_program: other_program, the_sub_program: other_sub_program) }

    before do
      user.roles = [assigned_role]
      EntityViewPermission.create!(entity: own_program, agency: user.agency)
      EntityViewPermission.create!(entity: other_program, agency: create(:agency))
    end

    it 'lists only submissions for programs assigned to the user agency' do
      get :index, params: { status: 'all' }
      expect(assigns(:vacancy_submissions)).to contain_exactly(own_submission)
    end

    it 'lists every submission for a can_view_programs user' do
      user.roles = [admin_role]
      get :index, params: { status: 'all' }
      expect(assigns(:vacancy_submissions)).to contain_exactly(own_submission, other_submission)
    end

    context 'as a reviewer without program permissions' do
      let(:reviewer_role) { create(:role, name: 'agency reviewer', can_view_opportunities: true, can_review_vacancies: true) }
      let!(:agency_mate_submission) do
        create(:vacancy_submission, :changes_requested, the_program: other_program, the_sub_program: other_sub_program, user: create(:user, agency: user.agency))
      end

      before { user.roles = [reviewer_role] }

      it 'lists only submissions made by users at the reviewer agency' do
        get :index, params: { status: 'all' }
        expect(assigns(:vacancy_submissions)).to contain_exactly(agency_mate_submission)
      end

      it 'shows a submission made by a user at the reviewer agency' do
        get :show, params: { id: agency_mate_submission.id }
        expect(response).to have_http_status(:ok)
      end

      it 'does not show another agency submission to the reviewer' do
        expect { get :show, params: { id: other_submission.id } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with rendered views' do
      render_views

      it 'offers only the user agency programs in the index program filter' do
        get :index
        expect(response.body).to include('Own Agency Program')
        expect(response.body).not_to include('Other Agency Program')
      end

      it 'offers only the user agency programs on the new submission form' do
        get :new
        expect(response.body).to include('Own Agency Program')
        expect(response.body).not_to include('Other Agency Program')
      end
    end

    it 'shows a submission for an assigned program' do
      get :show, params: { id: own_submission.id }
      expect(response).to have_http_status(:ok)
    end

    it 'does not show a submission for another agency program' do
      expect { get :show, params: { id: other_submission.id } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not open another agency submission for editing' do
      expect { get :edit, params: { id: other_submission.id } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not approve another agency submission' do
      expect { post :approve, params: { id: other_submission.id } }.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_submission.reload.status).to eq('return_changes_requested')
    end

    it 'rejects creating a submission for another agency program' do
      params = {
        vacancy_submission: {
          program_id: other_program.id,
          sub_program_id: other_sub_program.id,
          units: { '0' => { building_id: other_sub_program.building_id, unit_number: '1A' } },
        },
      }

      expect { post :create, params: params }.not_to change(VacancySubmission, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects moving a submission to another agency program' do
      params = {
        id: own_submission.id,
        vacancy_submission: {
          program_id: other_program.id,
          sub_program_id: other_sub_program.id,
          units: { '0' => { building_id: other_sub_program.building_id, unit_number: '1A' } },
        },
      }

      patch :update, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(own_submission.reload.program_id).to eq(own_program.id)
    end

    it 'does not render sections for another agency sub-program' do
      expect do
        get :sub_program_section, params: { section: 'vacancy', sub_program_id: other_sub_program.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'when editing a saved submission for a program the user cannot access' do
      let(:reviewer_submitter_role) do
        create(
          :role,
          name: 'agency reviewer submitter',
          can_view_opportunities: true,
          can_add_vacancies: true,
          can_review_vacancies: true,
        )
      end
      let(:new_building) { create(:building) }
      let!(:sibling_sub_program) { create(:sub_program, program: other_program, program_type: 'Project-Based', building: create(:building)) }
      let!(:agency_mate_submission) do
        create(:vacancy_submission, :changes_requested, the_program: other_program, the_sub_program: other_sub_program, user: create(:user, agency: user.agency))
      end

      before { user.roles = [reviewer_submitter_role] }

      def update_params(sub_program)
        {
          id: agency_mate_submission.id,
          vacancy_submission: {
            program_id: other_program.id,
            sub_program_id: sub_program.id,
            units: { '0' => { building_id: new_building.id, unit_number: '2B' } },
          },
        }
      end

      it 'offers only the saved program and sub-program on the edit form' do
        get :edit, params: { id: agency_mate_submission.id }

        expect(assigns(:programs)).to contain_exactly(other_program)
        expect(assigns(:programs_data).flat_map { |p| p[:sub_programs].pluck(:id) }).to contain_exactly(other_sub_program.id)
      end

      it 'offers the saved sub-program on the edit form after it is closed' do
        other_sub_program.update!(closed: true)

        get :edit, params: { id: agency_mate_submission.id }

        expect(assigns(:programs_data).flat_map { |p| p[:sub_programs].pluck(:id) }).to contain_exactly(other_sub_program.id)
      end

      it 'saves changes that keep the saved program and sub-program' do
        patch :update, params: update_params(other_sub_program)

        expect(response).to redirect_to(vacancy_submission_path(agency_mate_submission))
        expect(agency_mate_submission.reload.draft_data['units'][0]['building_id'].to_i).to eq(new_building.id)
      end

      it 'rejects switching to a different sub-program of the saved program' do
        patch :update, params: update_params(sibling_sub_program)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(agency_mate_submission.reload.sub_program_id).to eq(other_sub_program.id)
      end

      it 'renders sections for the saved sub-program' do
        get :sub_program_section, params: { section: 'vacancy', sub_program_id: other_sub_program.id, vacancy_submission_id: agency_mate_submission.id }
        expect(response).to have_http_status(:ok)
      end

      it 'does not render sections for a different sub-program of the saved program' do
        expect do
          get :sub_program_section, params: { section: 'vacancy', sub_program_id: sibling_sub_program.id, vacancy_submission_id: agency_mate_submission.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
