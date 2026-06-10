# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmissionNote, type: :model do
  let(:submission) { create(:vacancy_submission) }
  let(:user)       { create(:user) }

  describe 'validations' do
    it 'is valid with all required fields' do
      note = described_class.new(
        vacancy_submission: submission,
        user:               user,
        note_type:          'status_change',
        body:               'Status changed to Active.',
      )
      expect(note).to be_valid
    end

    it 'is valid without a user (system entry)' do
      note = described_class.new(
        vacancy_submission: submission,
        user:               nil,
        note_type:          'status_change',
        body:               'Status changed.',
      )
      expect(note).to be_valid
    end

    it 'is invalid with an unknown note_type' do
      note = described_class.new(
        vacancy_submission: submission,
        note_type:          'unknown',
        body:               'Some text',
      )
      expect(note).not_to be_valid
      expect(note.errors[:note_type]).to be_present
    end

    it 'is invalid without a body' do
      note = described_class.new(
        vacancy_submission: submission,
        note_type:          'reviewer_note',
        body:               '',
      )
      expect(note).not_to be_valid
      expect(note.errors[:body]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to a vacancy_submission' do
      note = create(:vacancy_submission_note, vacancy_submission: submission)
      expect(note.vacancy_submission).to eq(submission)
    end

    it 'belongs to a user optionally' do
      note = create(:vacancy_submission_note, user: user, vacancy_submission: submission)
      expect(note.user).to eq(user)
    end
  end
end
