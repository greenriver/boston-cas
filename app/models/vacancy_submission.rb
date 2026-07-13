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

  store_accessor :draft_data,
                 :program_id, :sub_program_id, :route, :is_voucher, :units,
                 :required_document_names, :notes

  # This maps accessibility features to rules, it's unclear if these should always be enforced
  # or if we need a mechanism to specify they are optional.  For instance, someone who isn't
  # a wheelchair user can live comfortably in a building that is wheelchair accessible.
  ACCESSIBILITY_OPTIONS = {
    'Wheelchair accessible unit' => Rules::Wheelchair,
    'Wheelchair accessible building' => Rules::Wheelchair,
    'Elevator to unit' => Rules::Elevator,
    'Ground floor unit' => Rules::Elevator,
  }.freeze

  STATUSES = ['awaiting_approval', 'return_changes_requested', 'active'].freeze
  REVIEW_QUEUE_STATUSES = ['awaiting_approval', 'return_changes_requested'].freeze

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

  def self.derive_route(sub_program)
    sub_program&.match_route&.title
  end

  def self.derive_is_voucher(sub_program)
    sub_program&.program_type == 'Tenant-Based'
  end

  def program_id
    super&.to_i
  end

  def sub_program_id
    super&.to_i
  end

  def voucher?
    is_voucher
  end

  def site_display
    return ['N/A'] if voucher?

    Array(units).map do |u|
      [
        u['street'],
        u['unit_number'],
        u['city'],
        u['state'],
        u['zip'],
      ].compact.reject(&:blank?).join(', ').presence
    end
  end

  def voucher_type_display
    voucher? ? 'Voucher' : 'Physical Unit'
  end

  def status_display
    {
      'awaiting_approval' => 'Awaiting Approval',
      'return_changes_requested' => 'Return / Changes Requested',
      'active' => 'Active',
    }[status] || status.to_s.humanize
  end

  def bedrooms_display
    return ['—'] if voucher?

    Array(units).map { |u| u['bedrooms'] }.compact.reject(&:blank?)
  end

  def changes_requested_display
    return '—' if status != 'return_changes_requested'

    vacancy_submission_notes.select { |n| n.note_type == 'reviewer_note' }.last&.body || '—'
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
    errors.add(:program_id, :blank) if program_id.blank?
    errors.add(:sub_program_id, :blank) if sub_program_id.blank?
    validate_units
  end

  def validate_units
    unit_list = Array(units)
    if unit_list.empty?
      errors.add(:units, :blank)
      return
    end
    if voucher?
      unit_list.each { |u| errors.add(:units, 'each voucher must have a name') if u['name'].blank? }
    else
      unit_list.each do |u|
        errors.add(:units, 'each unit must have a street address') if u['street'].blank?
        errors.add(:units, 'each unit must have a city') if u['city'].blank?
        errors.add(:units, 'each unit must have a state') if u['state'].blank?
        errors.add(:units, 'each unit must have a zip code') if u['zip'].blank?
      end
    end
  end
end
