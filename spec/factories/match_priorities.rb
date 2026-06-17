###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

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
  factory :priority_assessment_score_random_tie_breaker, class: 'MatchPrioritization::AssessmentScoreRandomTieBreaker' do
    active { true }
  end
  factory :priority_rank, class: 'MatchPrioritization::Rank' do
    active { true }
  end
  factory :priority_match_group_disability, class: 'MatchPrioritization::MatchGroup' do
    active { true }
  end
  factory :priority_family_psh, class: 'MatchPrioritization::FamilyPsh' do
    active { true }
  end
  factory :priority_rrh_and_th, class: 'MatchPrioritization::RrhAndTh' do
    active { true }
  end
  factory :priority_low_income_subsidies, class: 'MatchPrioritization::LowIncomeSubsidies' do
    active { true }
  end
end
