###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module VacancySubmissions
  # Resolves recipients and enqueues the vacancy-submission workflow emails.
  # Called from the controller after a transition commits so mail is never
  # enqueued inside the transaction that performs the state change.
  class Notifier
    def initialize(vacancy_submission)
      @vacancy_submission = vacancy_submission
    end

    def notify_submitted!
      reviewers.each do |reviewer|
        VacancySubmissionsMailer.submitted_for_review(@vacancy_submission, reviewer).deliver_later
      end
    end

    def notify_resubmitted!
      reviewers.each do |reviewer|
        VacancySubmissionsMailer.resubmitted_for_review(@vacancy_submission, reviewer).deliver_later
      end
    end

    def notify_changes_requested!
      submitter = @vacancy_submission.user
      return if submitter.blank?

      VacancySubmissionsMailer.changes_requested(@vacancy_submission, submitter).deliver_later
    end

    private

    def reviewers
      User.vacancy_reviewers
    end
  end
end
