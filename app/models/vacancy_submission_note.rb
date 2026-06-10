# frozen_string_literal: true

class VacancySubmissionNote < ApplicationRecord
  NOTE_TYPES = ['reviewer_note', 'status_change'].freeze

  belongs_to :vacancy_submission
  belongs_to :user, optional: true

  ACTION_LABELS = {
    'Initial submission' => 'Submitted',
    'Approved'           => 'Approved',
    'Resubmitted'        => 'Resubmitted',
    'Updated:'           => 'Submission Edited',
  }.freeze

  validates :note_type, inclusion: { in: NOTE_TYPES }
  validates :body, presence: true

  def action_label
    return 'Return / Changes Requested' if note_type == 'reviewer_note'

    ACTION_LABELS.detect { |prefix, _| body.start_with?(prefix) }&.last || 'Status Change'
  end
end
