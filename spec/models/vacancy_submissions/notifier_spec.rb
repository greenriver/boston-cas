###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmissions::Notifier do
  let(:submitter) { create :user }
  let(:reviewer_role) { create(:role, name: 'vacancy reviewer', can_review_vacancies: true) }
  let(:all_programs_reviewer_role) { create(:role, name: 'all programs vacancy reviewer', can_review_vacancies: true, can_view_programs: true) }
  # Same agency as the submitter.
  let(:reviewer_one) { create(:user_two, agency: submitter.agency, roles: [reviewer_role]) }
  # Another agency, but can view every program.
  let(:reviewer_two) { create(:user_three, roles: [all_programs_reviewer_role]) }
  # Another agency, with no access to the submission.
  let(:outside_reviewer) { create(:user_four, roles: [reviewer_role]) }
  let(:submission) { create :vacancy_submission, user: submitter }
  let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

  subject(:notifier) { described_class.new(submission) }

  describe '#notify_submitted!' do
    it 'enqueues a submitted_for_review email to each reviewer who can see the submission' do
      outside_reviewer

      expect(VacancySubmissionsMailer).to receive(:submitted_for_review).with(submission, reviewer_one).and_return(delivery)
      expect(VacancySubmissionsMailer).to receive(:submitted_for_review).with(submission, reviewer_two).and_return(delivery)
      expect(delivery).to receive(:deliver_later).twice

      notifier.notify_submitted!
    end
  end

  describe '#notify_resubmitted!' do
    it 'enqueues a resubmitted_for_review email to each reviewer who can see the submission' do
      outside_reviewer

      expect(VacancySubmissionsMailer).to receive(:resubmitted_for_review).with(submission, reviewer_one).and_return(delivery)
      expect(VacancySubmissionsMailer).to receive(:resubmitted_for_review).with(submission, reviewer_two).and_return(delivery)
      expect(delivery).to receive(:deliver_later).twice

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
