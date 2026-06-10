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
