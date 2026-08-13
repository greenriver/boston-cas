###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :vacancy_submission_note do
    association :vacancy_submission
    association :user
    note_type { 'status_change' }
    body      { 'Status changed to Active.' }

    trait :reviewer_note do
      note_type { 'reviewer_note' }
      body      { 'Please update the street address.' }
    end
  end
end
