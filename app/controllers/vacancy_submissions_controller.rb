###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class VacancySubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_opportunities!, only: [:index, :new, :create]
  before_action :require_can_submit_or_review_vacancies!, only: [:show]
  before_action :require_can_review_vacancies!, only: [:approve, :return_submission]
  before_action :require_can_add_vacancies!, only: [:resubmit, :edit, :update]

  def index
    @search_string = params[:q]
    @vacancy_submissions = VacancySubmission
      .filtered(search: params[:q], status_filter: params[:status])
      .order(updated_at: :desc)
      .page(params[:page]).per(25)

    program_ids = @vacancy_submissions.map(&:program_id).uniq.compact
    @programs_by_id = Program.where(id: program_ids).index_by(&:id)
  end

  def show
    @submission = VacancySubmission.includes(user: [:contact, :agency]).find(params[:id])
    @notes = @submission.vacancy_submission_notes.includes(:user).order(created_at: :asc)
    @program = Program.find_by(id: @submission.program_id)
    @sub_program = SubProgram.find_by(id: @submission.sub_program_id)
  end

  def new
    @vacancy_submission = VacancySubmission.new
    load_form_data
  end

  def create
    program = Program.find_by(id: submission_params[:program_id])
    sub_program = SubProgram.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @vacancy_submission = VacancySubmission.new(
        program_id: submission_params[:program_id],
        sub_program_id: submission_params[:sub_program_id],
      )
      @vacancy_submission.errors.add(:base, 'Program and sub-program are required')
      load_form_data
      return render :new, status: :unprocessable_entity
    end

    is_voucher = VacancySubmission.derive_is_voucher(sub_program)
    resource_type = VacancySubmission.derive_resource_type(program)

    draft_data = {
      'program_id' => program.id,
      'sub_program_id' => sub_program.id,
      'resource_type' => resource_type,
      'is_voucher' => is_voucher,
    }

    unless is_voucher
      draft_data.merge!(
        'unit_address_street' => submission_params[:unit_address_street],
        'unit_address_unit_number' => submission_params[:unit_address_unit_number],
        'unit_address_city' => submission_params[:unit_address_city],
        'unit_address_state' => submission_params[:unit_address_state],
        'unit_address_zip' => submission_params[:unit_address_zip],
      )
    end

    @vacancy_submission = VacancySubmission.new(
      user: current_user,
      status: 'awaiting_approval',
      draft_data: draft_data,
    )

    if @vacancy_submission.save
      @vacancy_submission.vacancy_submission_notes.create!(
        user: current_user,
        note_type: 'status_change',
        body: 'Initial submission.',
      )
      redirect_to vacancy_submissions_path, notice: 'Vacancy submission created.'
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @submission = VacancySubmission.find(params[:id])
    return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be edited in its current state.' unless @submission.resubmittable?

    @program = Program.find_by(id: @submission.program_id)
    @sub_program = SubProgram.find_by(id: @submission.sub_program_id)
    load_form_data
  end

  def update
    @submission = VacancySubmission.find(params[:id])
    return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be edited in its current state.' unless @submission.resubmittable?

    program = Program.find_by(id: submission_params[:program_id])
    sub_program = SubProgram.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @program = Program.find_by(id: @submission.program_id)
      @sub_program = SubProgram.find_by(id: @submission.sub_program_id)
      load_form_data
      @submission.errors.add(:base, 'Program and sub-program are required')
      return render :edit, status: :unprocessable_entity
    end

    is_voucher = VacancySubmission.derive_is_voucher(sub_program)
    resource_type = VacancySubmission.derive_resource_type(program)

    draft_data = @submission.draft_data.merge(
      'program_id' => program.id,
      'sub_program_id' => sub_program.id,
      'resource_type' => resource_type,
      'is_voucher' => is_voucher,
    )

    unless is_voucher
      draft_data.merge!(
        'unit_address_street' => submission_params[:unit_address_street],
        'unit_address_unit_number' => submission_params[:unit_address_unit_number],
        'unit_address_city' => submission_params[:unit_address_city],
        'unit_address_state' => submission_params[:unit_address_state],
        'unit_address_zip' => submission_params[:unit_address_zip],
      )
    end

    changed_sections = detect_changed_sections(@submission.draft_data, draft_data)

    if @submission.update(draft_data: draft_data)
      if changed_sections.any?
        @submission.vacancy_submission_notes.create!(
          user: current_user,
          note_type: 'status_change',
          body: "Updated: #{changed_sections.join(', ')}.",
        )
      end
      redirect_to vacancy_submission_path(@submission), notice: 'Submission updated.'
    else
      @program = program
      @sub_program = sub_program
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    submission = VacancySubmission.find(params[:id])
    return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be approved in its current state.' unless submission.approvable?

    submission.approve!(user: current_user)
    redirect_to vacancy_submission_path(submission), notice: 'Submission approved.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(submission), alert: "Could not approve: #{e.message}"
  end

  def return_submission
    submission = VacancySubmission.find(params[:id])

    return redirect_to vacancy_submission_path(submission), alert: 'Note is required when returning a submission.' if params[:body].blank?

    return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be returned in its current state.' unless submission.returnable?

    submission.return_for_changes!(body: params[:body], user: current_user)
    redirect_to vacancy_submission_path(submission), notice: 'Submission returned for changes.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(submission), alert: "Could not return submission: #{e.message}"
  end

  def resubmit
    submission = VacancySubmission.find(params[:id])
    return redirect_to vacancy_submission_path(submission), alert: 'This submission cannot be resubmitted in its current state.' unless submission.resubmittable?

    submission.resubmit!(user: current_user)
    redirect_to vacancy_submission_path(submission), notice: 'Submission resubmitted for review.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(submission), alert: "Could not resubmit: #{e.message}"
  end

  private

  def detect_changed_sections(old_data, new_data)
    sections = []
    sections << 'Program' if old_data['program_id'] != new_data['program_id']
    sections << 'Sub-Program' if old_data['sub_program_id'] != new_data['sub_program_id']
    sections << 'Unit Type' if old_data['is_voucher'] != new_data['is_voucher']

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
      :unit_address_city, :unit_address_state, :unit_address_zip
    )
  end

  def load_form_data
    @programs = Program.order(:name).includes(:sub_programs, :match_route)
    @programs_data = @programs.map do |p|
      {
        id: p.id,
        name: p.name,
        resource_type: VacancySubmission.derive_resource_type(p),
        sub_programs: p.sub_programs.order(:name).map do |sp|
          {
            id: sp.id,
            name: sp.name.presence || '(unnamed)',
            is_voucher: VacancySubmission.derive_is_voucher(sp),
            program_type: sp.program_type,
          }
        end,
      }
    end
  end
end
