module VacancySubmissionsHelper
  STATUS_BADGE_CLASSES = {
    'awaiting_approval'        => 'badge-warning',
    'return_changes_requested' => 'badge-danger',
    'active'                   => 'badge-success',
  }.freeze

  STATUS_DISPLAY = {
    'awaiting_approval'        => 'Awaiting Approval',
    'return_changes_requested' => 'Return / Changes Requested',
    'active'                   => 'Active',
  }.freeze

  def vacancy_submission_status_badge(submission)
    label = STATUS_DISPLAY[submission.status] || submission.status.humanize
    css   = STATUS_BADGE_CLASSES[submission.status] || 'badge-secondary'
    content_tag(:span, label, class: "badge #{css}")
  end
end
