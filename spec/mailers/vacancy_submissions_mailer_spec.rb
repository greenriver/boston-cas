###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmissionsMailer, type: :mailer do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FQDN').and_return('example.com')
  end

  let(:submitter) { create :user, first_name: 'Sub', last_name: 'Mitter' }
  let(:reviewer)  { create :user_two, first_name: 'Rev', last_name: 'Iewer' }
  let(:submission) { create :vacancy_submission, user: submitter }

  describe '#submitted_for_review' do
    subject(:mail) { described_class.submitted_for_review(submission, reviewer) }

    it 'is addressed to the reviewer with the awaiting-review subject' do
      expect(mail.to).to eq([reviewer.email])
      expect(mail.subject).to eq('Vacancy submission awaiting review')
    end

    it 'includes the translatable intro, program name, and submission link in the text part' do
      body = mail.text_part.body.to_s
      expect(body).to include('A new vacancy submission is awaiting your review.')
      expect(body).to include('Test Program')
      expect(body).to include("/vacancy_submissions/#{submission.id}")
    end

    it 'renders the markdown body as HTML in the html part' do
      html = mail.html_part.body.to_s
      expect(html).to include('<a href=')
      expect(html).to include("/vacancy_submissions/#{submission.id}")
      expect(html).to include('A new vacancy submission is awaiting your review.')
    end
  end

  describe '#resubmitted_for_review' do
    subject(:mail) { described_class.resubmitted_for_review(submission, reviewer) }

    it 'is addressed to the reviewer with the resubmitted subject' do
      expect(mail.to).to eq([reviewer.email])
      expect(mail.subject).to eq('Vacancy submission resubmitted for review')
    end

    it 'includes the resubmitted intro and program name' do
      body = mail.text_part.body.to_s
      expect(body).to include('A vacancy submission has been resubmitted for your review.')
      expect(body).to include('Test Program')
    end
  end

  describe '#changes_requested' do
    let(:submission) { create :vacancy_submission, :changes_requested, user: submitter }

    before do
      submission.vacancy_submission_notes.create!(
        user: reviewer,
        note_type: 'reviewer_note',
        body: 'Please add the elevator details.',
      )
    end

    subject(:mail) { described_class.changes_requested(submission, submitter) }

    it 'is addressed to the submitter with the changes-requested subject' do
      expect(mail.to).to eq([submitter.email])
      expect(mail.subject).to eq('Changes requested on your vacancy submission')
    end

    it 'includes the changes-requested intro without leaking the reviewer note body' do
      body = mail.text_part.body.to_s
      expect(body).to include('Changes have been requested on your vacancy submission before it can be approved.')
      expect(body).to include("/vacancy_submissions/#{submission.id}")
      expect(body).not_to include('Please add the elevator details.')
      expect(body).not_to include('Requested changes')
    end

    it 'does not render the reviewer note in the html part' do
      html = mail.html_part.body.to_s
      expect(html).not_to include('Please add the elevator details.')
    end
  end
end
