###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module VacancySubmissionsHelper
  STATUS_BADGE_CLASSES = {
    'awaiting_approval' => 'badge-warning',
    'return_changes_requested' => 'badge-danger',
    'active' => 'badge-success',
  }.freeze

  STATUS_DISPLAY = {
    'awaiting_approval' => 'Awaiting Approval',
    'return_changes_requested' => 'Return / Changes Requested',
    'active' => 'Active',
  }.freeze

  def vacancy_submission_status_badge(submission)
    label = STATUS_DISPLAY[submission.status] || submission.status.humanize
    css   = STATUS_BADGE_CLASSES[submission.status] || 'badge-secondary'
    content_tag(:span, label, class: "badge #{css}")
  end

  # Options for the unit's building select2 dropdown. The visible label is
  # "Name (street address)" so type-ahead matches on either the name or the
  # street; each option carries the name and full address as data attributes so
  # the picked building's details can be shown below the dropdown. Memoized so
  # rendering many unit rows only queries buildings once per request.
  def vacancy_building_select_options(selected_id)
    @_vacancy_building_options ||= Building.order(:name).map do |building|
      label = building.address.present? ? "#{building.name} (#{building.address})" : building.name
      [
        label,
        building.id,
        { data: { name: building.name, address: building.building_address.join(', ') } },
      ]
    end
    options_for_select(@_vacancy_building_options, selected_id&.to_i)
  end
end
