###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class VacancySubmissionsController < ApplicationController
  SECTIONS = {
    'route' => ->(sp, _vs) {
      { partial: 'vacancy_submissions/route',
        route: VacancySubmission.derive_route(sp) }
    },
    'requirements' => ->(sp, _vs) {
      { partial: 'requirement_manager/inherited_rules',
        inheritee: sp, show_label: false }
    },
    'required_documents' => ->(sp, vs) {
      { partial: 'vacancy_submissions/required_documents',
        sub_program: sp,
        vacancy_submission: vs }
    },
    'vacancy' => ->(sp, vs) {
      { partial: 'vacancy_submissions/vacancy',
        sub_program: sp,
        vacancy_submission: vs,
        is_voucher: VacancySubmission.derive_is_voucher(sp) }
    },
  }.freeze
  before_action :authenticate_user!
  before_action :require_can_view_opportunities!, only: [:index, :new, :create, :sub_program_section]
  before_action :require_can_submit_or_review_vacancies!, only: [:show]
  before_action :require_can_review_vacancies!, only: [:approve, :return_submission]
  before_action :require_can_add_vacancies!, only: [:resubmit, :edit, :update]
  before_action :load_submission, only: [:approve, :return_submission, :resubmit]
  before_action :load_resubmittable_submission, only: [:edit, :update]

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
    @sub_program = @program.sub_programs.find_by(id: @submission.sub_program_id)
  end

  def new
    @vacancy_submission = VacancySubmission.new
    load_form_data
  end

  def create
    program = Program.find_by(id: submission_params[:program_id])
    sub_program = program&.sub_programs&.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @vacancy_submission = VacancySubmission.new(
        program_id: submission_params[:program_id],
        sub_program_id: submission_params[:sub_program_id],
      )
      @vacancy_submission.errors.add(:program_id, :blank) unless program
      @vacancy_submission.errors.add(:sub_program_id, :blank) unless sub_program
      load_form_data
      return render :new, status: :unprocessable_entity
    end

    @vacancy_submission = VacancySubmission.new(
      user: current_user,
      status: 'awaiting_approval',
      draft_data: build_draft_data(program: program, sub_program: sub_program),
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
    @program = Program.find_by(id: @submission.program_id)
    @sub_program = @program.sub_programs.find_by(id: @submission.sub_program_id)
    load_form_data
  end

  def update
    program = Program.find_by(id: submission_params[:program_id])
    sub_program = program&.sub_programs&.find_by(id: submission_params[:sub_program_id])

    unless program && sub_program
      @program = Program.find_by(id: @submission.program_id)
      @sub_program = @program&.sub_programs&.find_by(id: @submission.sub_program_id)
      load_form_data
      @submission.errors.add(:program_id, :blank) unless program
      @submission.errors.add(:sub_program_id, :blank) unless sub_program
      return render :edit, status: :unprocessable_entity
    end

    draft_data = @submission.draft_data.merge(build_draft_data(program: program, sub_program: sub_program))

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

  def sub_program_section
    config = SECTIONS[params[:section]]
    return head :not_found unless config

    sub_program = SubProgram.find(params[:sub_program_id])
    vacancy_submission = if params[:vacancy_submission_id].present?
      VacancySubmission.find(params[:vacancy_submission_id])
    else
      VacancySubmission.new
    end
    vacancy_submission.required_document_names = Array(params[:required_document_names]) if params[:required_document_names].present?
    vacancy_submission.units = normalize_units(params[:units]) if params[:units].present?

    locals = config.call(sub_program, vacancy_submission)
    render partial: locals.delete(:partial), locals: locals
  end

  def approve
    return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be approved in its current state.' unless @submission.approvable?

    @submission.approve!(user: current_user)
    redirect_to vacancy_submission_path(@submission), notice: 'Submission approved.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(@submission), alert: "Could not approve: #{e.message}"
  end

  def return_submission
    return redirect_to vacancy_submission_path(@submission), alert: 'Note is required when returning a submission.' if params[:body].blank?

    return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be returned in its current state.' unless @submission.returnable?

    @submission.return_for_changes!(body: params[:body], user: current_user)
    redirect_to vacancy_submission_path(@submission), notice: 'Submission returned for changes.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(@submission), alert: "Could not return submission: #{e.message}"
  end

  def resubmit
    return redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be resubmitted in its current state.' unless @submission.resubmittable?

    @submission.resubmit!(user: current_user)
    redirect_to vacancy_submission_path(@submission), notice: 'Submission resubmitted for review.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to vacancy_submission_path(@submission), alert: "Could not resubmit: #{e.message}"
  end

  private

  def load_submission
    @submission = VacancySubmission.find(params[:id])
  end

  def load_resubmittable_submission
    @submission = VacancySubmission.find(params[:id])
    redirect_to vacancy_submission_path(@submission), alert: 'This submission cannot be edited in its current state.' unless @submission.resubmittable?
  end

  def build_draft_data(program:, sub_program:)
    {
      'program_id' => program.id,
      'sub_program_id' => sub_program.id,
      'route' => VacancySubmission.derive_route(sub_program),
      'is_voucher' => VacancySubmission.derive_is_voucher(sub_program),
      'units' => normalize_units(submission_params[:units]),
      'required_document_names' => Array(submission_params[:required_document_names]),
    }
  end

  def detect_changed_sections(old_data, new_data)
    sections = []
    sections << 'Program' if old_data['program_id'] != new_data['program_id']
    sections << 'Sub-Program' if old_data['sub_program_id'] != new_data['sub_program_id']
    sections << 'Unit Type' if old_data['is_voucher'] != new_data['is_voucher']
    sections << 'Vacancy' if old_data['units'].to_json != new_data['units'].to_json
    sections << 'Required Documents' if old_data['required_document_names'] != new_data['required_document_names']
    sections
  end

  def require_can_submit_or_review_vacancies!
    not_authorized! unless can_add_vacancies? || can_review_vacancies?
  end

  def submission_params
    params.require(:vacancy_submission).permit(
      :program_id, :sub_program_id,
      units: [
        :name, :street, :unit_number, :city, :state, :zip,
        :date_ready, :age_limit, :bedrooms,
        shared_spaces: [],
        amenities: [],
        attributes: [:name, :value],
        media_links: [:url, :label],
        requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
      ],
      required_document_names: []
    )
  end

  def normalize_units(units_params)
    return [] if units_params.blank?

    units_params.values.map do |unit|
      h = unit.respond_to?(:to_unsafe_h) ? unit.to_unsafe_h : unit.to_h
      h['attributes'] = Array(h['attributes']&.values)
      h['media_links'] = Array(h['media_links']&.values)
      # requirements_attributes comes from the form submit; requirements (as a
      # numeric-keyed hash) comes from forward-params on re-render after failure.
      h['requirements'] = if h.key?('requirements_attributes')
        normalize_requirements(h.delete('requirements_attributes'))
      else
        reqs = h['requirements']
        reqs.is_a?(Hash) ? reqs.values : Array(reqs)
      end
      h
    end
  end

  def normalize_requirements(reqs_params)
    return [] if reqs_params.blank?

    reqs_params.values.reject { |r| r['_destroy'].to_s == '1' }.map do |r|
      { 'rule_id' => r['rule_id'].to_s, 'positive' => r['positive'].to_s, 'variable' => r['variable'].to_s }
    end
  end

  def load_form_data
    @programs = Program.order(:name).includes(:sub_programs, :match_route)
    @programs_data = @programs.map do |p|
      {
        id: p.id,
        name: p.name,
        resource_type: nil,
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
