# frozen_string_literal: true

class VacancySubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_opportunities!, only: [:index, :new, :create]
  before_action :require_can_submit_or_review_vacancies!, only: [:show]
  before_action :require_can_review_vacancies!, only: [:approve, :return_submission]
  before_action :require_can_add_vacancies!, only: [:resubmit, :edit, :update]

  def index
    @vacancy_submissions = VacancySubmission
      .filtered(search: params[:q], status_filter: params[:status])
      .order(updated_at: :desc)
      .page(params[:page]).per(25)

    program_ids = @vacancy_submissions.map { |vs| vs.draft_data['program_id'].to_i }.uniq.compact
    @programs_by_id = Program.where(id: program_ids).index_by(&:id)
  end

  def show
    @submission  = VacancySubmission.includes(user: [:contact, :agency]).find(params[:id])
    @notes       = @submission.vacancy_submission_notes.includes(:user).order(created_at: :asc)
    @program     = Program.find_by(id: @submission.draft_data['program_id'].to_i)
    @sub_program = SubProgram.find_by(id: @submission.draft_data['sub_program_id'].to_i)
  end

  def new
    @vacancy_submission = VacancySubmission.new
    load_form_data
  end

  def create
    program     = Program.find_by(id: submission_params[:program_id])
    sub_program = SubProgram.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @vacancy_submission = VacancySubmission.new
      @vacancy_submission.errors.add(:base, 'Program and sub-program are required')
      load_form_data
      return render :new, status: :unprocessable_entity
    end

    is_voucher    = VacancySubmission.derive_is_voucher(sub_program)
    resource_type = VacancySubmission.derive_resource_type(program)

    draft_data = {
      'program_id'     => program.id,
      'sub_program_id' => sub_program.id,
      'resource_type'  => resource_type,
      'is_voucher'     => is_voucher,
    }

    unless is_voucher
      draft_data.merge!(
        'unit_address_street'      => submission_params[:unit_address_street],
        'unit_address_unit_number' => submission_params[:unit_address_unit_number],
        'unit_address_city'        => submission_params[:unit_address_city],
        'unit_address_state'       => submission_params[:unit_address_state],
        'unit_address_zip'         => submission_params[:unit_address_zip],
      )
    end

    @vacancy_submission = VacancySubmission.new(
      user:       current_user,
      status:     'awaiting_approval',
      draft_data: draft_data,
    )

    if @vacancy_submission.save
      @vacancy_submission.vacancy_submission_notes.create!(
        user:      current_user,
        note_type: 'status_change',
        body:      'Initial submission.',
      )
      redirect_to vacancy_submissions_path, notice: 'Vacancy submission created.'
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @submission = VacancySubmission.find(params[:id])
    unless @submission.resubmittable?
      return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be edited in its current state.'
    end

    @program     = Program.find_by(id: @submission.draft_data['program_id'].to_i)
    @sub_program = SubProgram.find_by(id: @submission.draft_data['sub_program_id'].to_i)
    load_form_data
  end

  def update
    @submission = VacancySubmission.find(params[:id])
    unless @submission.resubmittable?
      return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be edited in its current state.'
    end

    program     = Program.find_by(id: submission_params[:program_id])
    sub_program = SubProgram.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @program     = Program.find_by(id: @submission.draft_data['program_id'].to_i)
      @sub_program = SubProgram.find_by(id: @submission.draft_data['sub_program_id'].to_i)
      load_form_data
      @submission.errors.add(:base, 'Program and sub-program are required')
      return render :edit, status: :unprocessable_entity
    end

    is_voucher    = VacancySubmission.derive_is_voucher(sub_program)
    resource_type = VacancySubmission.derive_resource_type(program)

    draft_data = @submission.draft_data.merge(
      'program_id'     => program.id,
      'sub_program_id' => sub_program.id,
      'resource_type'  => resource_type,
      'is_voucher'     => is_voucher,
    )

    unless is_voucher
      draft_data.merge!(
        'unit_address_street'      => submission_params[:unit_address_street],
        'unit_address_unit_number' => submission_params[:unit_address_unit_number],
        'unit_address_city'        => submission_params[:unit_address_city],
        'unit_address_state'       => submission_params[:unit_address_state],
        'unit_address_zip'         => submission_params[:unit_address_zip],
      )
    end

    changed_sections = detect_changed_sections(@submission.draft_data, draft_data)

    if @submission.update(draft_data: draft_data)
      if changed_sections.any?
        @submission.vacancy_submission_notes.create!(
          user:      current_user,
          note_type: 'status_change',
          body:      "Updated: #{changed_sections.join(', ')}.",
        )
      end
      redirect_to vacancy_submission_path(@submission), notice: 'Submission updated.'
    else
      @program     = program
      @sub_program = sub_program
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    submission = VacancySubmission.find(params[:id])
    unless submission.approvable?
      return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be approved in its current state.'
    end

    begin
      VacancySubmission.transaction do
        submission.update!(status: 'active')
        submission.vacancy_submission_notes.create!(
          user:      current_user,
          note_type: 'status_change',
          body:      'Approved — status changed to Active.',
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      return redirect_to vacancy_submission_path(submission), alert: "Could not approve: #{e.message}"
    end

    redirect_to vacancy_submission_path(submission), notice: 'Submission approved.'
  end

  def return_submission
    submission = VacancySubmission.find(params[:id])

    if params.permit(:body)[:body].blank?
      return redirect_to vacancy_submission_path(submission), alert: 'Note is required when returning a submission.'
    end

    unless submission.returnable?
      return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be returned in its current state.'
    end

    begin
      VacancySubmission.transaction do
        submission.update!(status: 'return_changes_requested')
        submission.vacancy_submission_notes.create!(
          user:      current_user,
          note_type: 'reviewer_note',
          body:      params.permit(:body)[:body],
        )
        submission.vacancy_submission_notes.create!(
          user:      current_user,
          note_type: 'status_change',
          body:      'Returned for changes.',
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      return redirect_to vacancy_submission_path(submission), alert: "Could not return submission: #{e.message}"
    end

    redirect_to vacancy_submission_path(submission), notice: 'Submission returned for changes.'
  end

  def resubmit
    submission = VacancySubmission.find(params[:id])
    unless submission.resubmittable?
      return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be resubmitted in its current state.'
    end

    begin
      VacancySubmission.transaction do
        submission.update!(status: 'awaiting_approval')
        submission.vacancy_submission_notes.create!(
          user:      current_user,
          note_type: 'status_change',
          body:      'Resubmitted for review.',
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      return redirect_to vacancy_submission_path(submission), alert: "Could not resubmit: #{e.message}"
    end

    redirect_to vacancy_submission_path(submission), notice: 'Submission resubmitted for review.'
  end

  private

  def detect_changed_sections(old_data, new_data)
    sections = []
    sections << 'Program'    if old_data['program_id'] != new_data['program_id']
    sections << 'Sub-Program' if old_data['sub_program_id'] != new_data['sub_program_id']

    address_keys = ['unit_address_street', 'unit_address_unit_number', 'unit_address_city', 'unit_address_state', 'unit_address_zip']
    sections << 'Address' if address_keys.any? { |k| old_data[k] != new_data[k] }

    sections
  end

  def require_can_submit_or_review_vacancies!
    not_authorized! unless can_add_vacancies? || can_review_vacancies?
  end

  def submission_params
    params.require(:vacancy_submission).permit(
      :program_id, :sub_program_id,
      :unit_address_street, :unit_address_unit_number,
      :unit_address_city, :unit_address_state, :unit_address_zip,
    )
  end

  def load_form_data
    @programs = Program.order(:name).includes(:sub_programs, :match_route)
    @programs_data = @programs.map do |p|
      {
        id:            p.id,
        name:          p.name,
        resource_type: VacancySubmission.derive_resource_type(p),
        sub_programs:  p.sub_programs.order(:name).map do |sp|
          {
            id:           sp.id,
            name:         sp.name,
            is_voucher:   VacancySubmission.derive_is_voucher(sp),
            program_type: sp.program_type,
          }
        end,
      }
    end
  end
end
