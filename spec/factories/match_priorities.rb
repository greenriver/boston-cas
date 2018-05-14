FactoryGirl.define do
  factory :priority_days_homeless, class: 'MatchPrioritization::DaysHomeless' do
    active true
  end
  factory :priority_first_date, class: 'MatchPrioritization::FirstDateHomeless' do
    active true
  end
  factory :priority_vispdat, class: 'MatchPrioritization::VispdatScore' do
    active true
  end
  factory :priority_vispdat_priority, class: 'MatchPrioritization::VispdatPriorityScore' do
    active true
  end
  factory :priority_days_homeless_last_three_years, class: 'MatchPrioritization::DaysHomelessLastThreeYears' do
    active true
  end
  factory :priority_assessment_score, class: 'MatchPrioritization::AssessmentScore' do
    active true
  end
end
