###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmissions::Notifier do
  let(:submitter) { create :user }
  let(:reviewer_one) { create :user_two }
  let(:reviewer_two) { create :user_three }
  let(:submission) { create :vacancy_submission, user: submitter }
  let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  subject(:notifier) { described_class.new(submission) }

  describe '#notify_submitted!' do
    it 'enqueues a submitted_for_review email to each reviewer' do
      allow(User).to receive(:vacancy_reviewers).and_return([reviewer_one, reviewer_two])

      expect(VacancySubmissionsMailer).to receive(:submitted_for_review).with(submission, reviewer_one).and_return(delivery)
      expect(VacancySubmissionsMailer).to receive(:submitted_for_review).with(submission, reviewer_two).and_return(delivery)
      expect(delivery).to receive(:deliver_later).twice

      notifier.notify_submitted!
    end
  end

  describe '#notify_resubmitted!' do
    it 'enqueues a resubmitted_for_review email to each reviewer' do
      allow(User).to receive(:vacancy_reviewers).and_return([reviewer_one])

      expect(VacancySubmissionsMailer).to receive(:resubmitted_for_review).with(submission, reviewer_one).and_return(delivery)
      expect(delivery).to receive(:deliver_later)

      notifier.notify_resubmitted!
    end
  end

  describe '#notify_changes_requested!' do
    it 'enqueues a changes_requested email to the submitter' do
      expect(VacancySubmissionsMailer).to receive(:changes_requested).with(submission, submitter).and_return(delivery)
      expect(delivery).to receive(:deliver_later)

      notifier.notify_changes_requested!
    end

    it 'does nothing when the submission has no submitter' do
      submission_without_user = instance_double(VacancySubmission, user: nil)

      expect(VacancySubmissionsMailer).not_to receive(:changes_requested)

      described_class.new(submission_without_user).notify_changes_requested!
    end
  end
end
