FactoryBot.define do
  factory :priority_days_homeless, class: 'MatchPrioritization::DaysHomeless' do
    active { true }
  end
  factory :priority_first_date, class: 'MatchPrioritization::FirstDateHomeless' do
    active { true }
  end
  factory :priority_vispdat, class: 'MatchPrioritization::VispdatScore' do
    active { true }
  end
  factory :priority_vispdat_priority, class: 'MatchPrioritization::VispdatPriorityScore' do
    active { true }
  end
  factory :priority_days_homeless_last_three_years, class: 'MatchPrioritization::DaysHomelessLastThreeYears' do
    active { true }
  end
  factory :priority_days_homeless_last_three_years_assessment_date, class: 'MatchPrioritization::DaysHomelessLastThreeYearsAssessmentDate' do
    active { true }
  end
  factory :priority_assessment_score, class: 'MatchPrioritization::AssessmentScore' do
    active { true }
  end
  factory :priority_assessment_score_funding_tie_breaker, class: 'MatchPrioritization::AssessmentScoreFundingTieBreaker' do
    active { true }
  end
  factory :priority_rank, class: 'MatchPrioritization::Rank' do
    active { true }
  end
  factory :priority_match_group_disability, class: 'MatchPrioritization::MatchGroup' do
    active { true }
  end
end
