###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class VacancySubmission < ApplicationRecord
  has_paper_trail

  belongs_to :user, optional: true
  has_many :vacancy_submission_notes, dependent: :destroy

  STATUSES = ['awaiting_approval', 'return_changes_requested', 'active'].freeze
  REVIEW_QUEUE_STATUSES = ['awaiting_approval', 'return_changes_requested'].freeze

  RESOURCE_TYPE_LABELS = {
    'MatchRoutes::HomelessSetAside' => 'Homeless Set Aside',
    'MatchRoutes::Default' => 'PSH Resource',
  }.freeze

  validates :status, inclusion: { in: STATUSES }
  validate :required_draft_fields

  scope :queue,     -> { where(status: REVIEW_QUEUE_STATUSES) }
  scope :by_status, ->(s) { where(status: s) }

  def self.filtered(search:, status_filter:)
    scope = all
    scope = scope.where('draft_data::text ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(search)}%") if search.present?
    case status_filter.to_s
    when 'queue', ''
      scope.queue
    when 'all'
      scope
    else
      scope.by_status(status_filter)
    end
  end

  def self.derive_resource_type(program)
    return 'Unknown' unless program&.match_route

    RESOURCE_TYPE_LABELS[program.match_route.class.name] ||
      program.match_route.class.name.demodulize.titleize
  end

  def self.derive_is_voucher(sub_program)
    sub_program&.program_type == 'Tenant-Based'
  end

  def site_display
    return '—' if draft_data['is_voucher']

    [
      draft_data['unit_address_street'],
      draft_data['unit_address_city'],
      draft_data['unit_address_state'],
      draft_data['unit_address_zip'],
    ].compact.reject(&:blank?).join(', ').presence || '—'
  end

  def voucher_type_display
    draft_data['is_voucher'] ? 'Voucher' : 'Physical Unit'
  end

  def status_display
    {
      'awaiting_approval' => 'Awaiting Approval',
      'return_changes_requested' => 'Return / Changes Requested',
      'active' => 'Active',
    }[status] || status.to_s.humanize
  end

  # Reviewers can approve from either queue state — including return_changes_requested —
  # as an override without requiring the submitter to go through the resubmit flow.
  def approvable?
    status.in?(REVIEW_QUEUE_STATUSES)
  end

  def returnable?
    status.in?(REVIEW_QUEUE_STATUSES)
  end

  def resubmittable?
    status == 'return_changes_requested'
  end

  def approve!(user:)
    transaction do
      update!(status: 'active')
      vacancy_submission_notes.create!(
        user: user,
        note_type: 'status_change',
        body: 'Approved — status changed to Active.',
      )
    end
  end

  def return_for_changes!(body:, user:)
    transaction do
      update!(status: 'return_changes_requested')
      vacancy_submission_notes.create!(
        user: user,
        note_type: 'reviewer_note',
        body: body,
      )
      vacancy_submission_notes.create!(
        user: user,
        note_type: 'status_change',
        body: 'Returned for changes.',
      )
    end
  end

  def resubmit!(user:)
    transaction do
      update!(status: 'awaiting_approval')
      vacancy_submission_notes.create!(
        user: user,
        note_type: 'status_change',
        body: 'Resubmitted for review.',
      )
    end
  end

  private

  def required_draft_fields
    errors.add(:base, 'Program is required')     if draft_data['program_id'].blank?
    errors.add(:base, 'Sub-program is required') if draft_data['sub_program_id'].blank?
    return if draft_data['is_voucher']

    errors.add(:base, 'Street address is required') if draft_data['unit_address_street'].blank?
    errors.add(:base, 'City is required')            if draft_data['unit_address_city'].blank?
    errors.add(:base, 'State is required')           if draft_data['unit_address_state'].blank?
    errors.add(:base, 'Zip code is required')        if draft_data['unit_address_zip'].blank?
  end
end
