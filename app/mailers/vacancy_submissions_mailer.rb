###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# Notifies staff about vacancy-submission workflow transitions. Delivered
# through the CAS Message/Contact pipeline (see DatabaseMailer). Email bodies
# are authored in Markdown from translatable fragments (Translation.translate)
# and rendered to HTML with Redcarpet via MarkdownHelper for the HTML part.
class VacancySubmissionsMailer < DatabaseMailer
  helper MarkdownHelper

  def submitted_for_review(vacancy_submission, reviewer)
    setup(vacancy_submission, reviewer)
    @body = reviewer_body('A new vacancy submission is awaiting your review.')
    mail to: reviewer.email, subject: Translation.translate('Vacancy submission awaiting review')
  end

  def resubmitted_for_review(vacancy_submission, reviewer)
    setup(vacancy_submission, reviewer)
    @body = reviewer_body('A vacancy submission has been resubmitted for your review.')
    mail to: reviewer.email, subject: Translation.translate('Vacancy submission resubmitted for review')
  end

  def changes_requested(vacancy_submission, submitter)
    setup(vacancy_submission, submitter)
    @body = changes_requested_body
    mail to: submitter.email, subject: Translation.translate('Changes requested on your vacancy submission')
  end

  private

  def setup(vacancy_submission, recipient)
    @submission = vacancy_submission
    @recipient = recipient
    @url = vacancy_submission_url(@submission, host: ENV['FQDN'])
  end

  def reviewer_body(intro_key)
    [
      Translation.translate(intro_key),
      '',
      "- **#{Translation.translate('Program')}:** #{program_name}",
      "- **#{Translation.translate('Submitted by')}:** #{submitter_name}",
      '',
      "[#{Translation.translate('View submission')}](#{@url})",
    ].join("\n")
  end

  # Intentionally omits the reviewer's free-text note: it may contain
  # human-entered PII, so we link back to the app rather than emailing it.
  def changes_requested_body
    [
      Translation.translate('Changes have been requested on your vacancy submission before it can be approved.'),
      '',
      "- **#{Translation.translate('Program')}:** #{program_name}",
      "- **#{Translation.translate('Reviewer')}:** #{reviewer_name}",
      '',
      "[#{Translation.translate('View submission')}](#{@url})",
    ].join("\n")
  end

  def program_name
    Program.find_by(id: @submission.program_id)&.name || '—'
  end

  def submitter_name
    @submission.user&.name.presence || '—'
  end

  def reviewer_name
    @submission.vacancy_submission_notes.
      select { |n| n.note_type == 'reviewer_note' }.last&.user&.name.presence || 'the CAS Admin'
  end
end
