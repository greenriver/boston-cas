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

  # Accessibility options captured by the Unit#elevator_accessible boolean rather
  # than a Requirement rule — both simply set elevator_accessible to true.
  ELEVATOR_ACCESSIBILITY_OPTIONS = ['Elevator to unit', 'Ground floor unit'].freeze

  # Accessibility checkboxes shown on the vacancy form. Wheelchair options map to
  # the Requirement rule they enforce; the elevator / ground-floor options map to
  # nil because they are captured by the Unit#elevator_accessible boolean
  # (see ELEVATOR_ACCESSIBILITY_OPTIONS) rather than a Requirement.
  #
  # It's unclear if the wheelchair requirements should always be enforced or if we
  # need a mechanism to mark them optional. For instance, someone who isn't a
  # wheelchair user can live comfortably in a wheelchair accessible building.
  ACCESSIBILITY_OPTIONS = {
    'Wheelchair accessible unit' => Rules::Wheelchair,
    'Wheelchair accessible building' => Rules::Wheelchair,
  }.merge(ELEVATOR_ACCESSIBILITY_OPTIONS.index_with { nil }).freeze

  # Studio and 3+ bedrooms don't have a dedicated Rule yet, so we approximate
  # with Rules::BedroomExact until product decides how they should be modeled.
  BEDROOM_OPTIONS = {
    'SRO' => { rule_class: Rules::SroOk, variable: nil },
    'Studio' => { rule_class: Rules::BedroomExact, variable: 1 }, # approximation; TBD with product team
    'One bedroom' => { rule_class: Rules::BedroomExact, variable: 1 },
    'Two bedrooms' => { rule_class: Rules::BedroomExact, variable: 2 },
    'Three or more bedrooms' => { rule_class: Rules::BedroomExact, variable: 3 }, # collapses 3+ to exactly 3 for now
  }.freeze

  AGE_LIMIT_OPTIONS = {
    'N/A' => nil,
    '50+' => Rules::AgeGreaterThanFifty,
    '55+' => Rules::AgeGreaterThanFiftyFive,
    '60+' => Rules::AgeGreaterThanSixty,
  }.freeze

  SHARED_SPACE_OPTIONS = ['Kitchen', 'Living Room', 'Bathroom'].freeze

  STATUSES = ['awaiting_approval', 'return_changes_requested', 'active'].freeze
  REVIEW_QUEUE_STATUSES = ['awaiting_approval', 'return_changes_requested'].freeze

  validates :status, inclusion: { in: STATUSES }
  validate :required_draft_fields

  scope :queue,     -> { where(status: REVIEW_QUEUE_STATUSES) }
  scope :by_status, ->(s) { where(status: s) }
  scope :visible_by, ->(user) do
    return current_scope if user.can_view_programs? || user.can_edit_programs?

    submitter_ids = user.can_review_vacancies? ? User.where(agency_id: user.agency_id).select(:id) : [user.id]
    where("(draft_data ->> 'program_id')::integer IN (?)", Program.visible_or_editable_by(user).select(:id)).
      or(where(user_id: submitter_ids))
  end

  def self.filtered(program_id:, status_filter:)
    scope = all
    scope = scope.where("draft_data ->> 'program_id' = ?", program_id.to_s) if program_id.present?
    case status_filter.to_s
    when 'queue', ''
      scope.queue
    when 'all'
      scope
    else
      scope.by_status(status_filter)
    end
  end

  def self.program_ids_in_use
    distinct.pluck(Arel.sql("(draft_data ->> 'program_id')::integer")).compact
  end

  def self.derive_route(sub_program)
    sub_program&.match_route&.title
  end

  def self.derive_is_voucher(sub_program)
    sub_program&.program_type == 'Tenant-Based'
  end

  def self.http_url?(value)
    uri = URI.parse(value.to_s)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
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

  # Units have no database id. The form posts each unit's uid so the controller can
  # find the stored unit it came from. A unit saved without a uid gets one from its
  # stored position, which holds until the next successful save.
  def units_with_uids
    Array(units).each_with_index.map do |unit, index|
      unit['uid'].present? ? unit : unit.merge('uid' => "position-#{index}")
    end
  end

  def requirements_by_unit_uid
    units_with_uids.to_h { |unit| [unit['uid'], Array(unit['requirements'])] }
  end

  def site_display
    return ['N/A'] if voucher?

    Array(units).map do |u|
      building = Building.find_by(id: u['building_id'])
      next '—' if building.nil?

      [
        building.name,
        ("Unit #{u['unit_number']}" if u['unit_number'].present?),
        *building.building_address,
      ].compact.reject(&:blank?).join(', ').presence || '—'
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
      VacancySubmissions::Approval.new(self, user: user).call!
      vacancy_submission_notes.create!(
        user: user,
        note_type: 'status_change',
        body: 'Approved — status changed to Active.',
      )
    end
  end

  def return_for_changes!(body:, user:)
    transaction do
      # Returning is how a reviewer sends a submission back to be fixed, so it
      # must work even when the draft is invalid (e.g. units captured under an
      # older address mechanism). Only the reviewer note is required here; that
      # is enforced in the controller.
      self.status = 'return_changes_requested'
      save!(validate: false)
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
      errors.add(:units, voucher? ? 'Add at least one voucher' : 'Add at least one unit')
      return
    end
    unit_list.each_with_index do |unit, index|
      if voucher?
        add_unit_error(index, 'name', 'needs a name', 'Enter a name') if unit['name'].blank?
      else
        add_unit_error(index, 'building_id', 'needs a building', 'Select a building') if unit['building_id'].blank?
        add_unit_error(index, 'unit_number', 'needs a unit number', 'Enter a unit number') if unit['unit_number'].blank?
      end
      validate_requirement_variables(unit, index)
      validate_media_link_urls(unit, index)
    end
  end

  # unit_index and field locate the form input that the form marks with field_message. field is a
  # path under the unit: "media_links[0][url]" means vacancy_submission[units][<unit_index>][media_links][0][url].
  def add_unit_error(unit_index, field, message, field_message)
    label = "#{voucher? ? 'Voucher' : 'Unit'} #{unit_index + 1}"
    errors.add(:units, "#{label} #{message}", unit_index: unit_index, field: field, field_message: field_message)
  end

  def validate_media_link_urls(unit, unit_index)
    Array(unit['media_links']).each_with_index do |link, link_index|
      next if link['url'].blank? || self.class.http_url?(link['url'])

      add_unit_error(unit_index, "media_links[#{link_index}][url]", "media link #{link_index + 1} must be an http or https URL", 'Must be an http or https URL')
    end
  end

  # Requirements attached to a unit/voucher may reference a rule that needs a
  # variable (e.g. bedroom count, HMIS projects). The draft form can submit
  # such a rule with a blank variable, so guard it here rather than deferring
  # the failure to approval time.
  def validate_requirement_variables(unit, unit_index)
    Array(unit['requirements']).each_with_index do |req, req_index|
      next if req['rule_id'].blank? || req['variable'].present?

      rule = Rule.find_by(id: req['rule_id'])
      next unless rule&.variable_requirement?

      add_unit_error(unit_index, "requirements_attributes[#{req_index}][variable]", "requirement #{rule.name} requires a value", "#{rule.name} requires a value")
    end
  end
end
