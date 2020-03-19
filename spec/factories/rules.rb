FactoryBot.define do
  factory :female, class: 'Rules::Female' do
    name { 'Female' }
    verb { 'be' }
  end
  factory :male, class: 'Rules::Male' do
    name { 'Male' }
    verb { 'be' }
  end
  factory :veteran, class: 'Rules::Veteran' do
    name { 'Veteran' }
    verb { 'be' }
  end
  factory :sixteen_plus, class: 'Rules::AgeGreaterThanSixteen' do
    name { 'Age greater than 16' }
    verb { 'be' }
  end
  factory :eighteen_plus, class: 'Rules::AgeGreaterThanEightteen' do
    name { 'Age greater than 18' }
    verb { 'be' }
  end
  factory :twenty_five_plus, class: 'Rules::AgeGreaterThanTwentyFive' do
    name { 'Age greater than 25' }
    verb { 'be' }
  end
  factory :chronic_substance_use, class: 'Rules::ChronicSubstanceUse' do
    name { 'Chronic Substance Use' }
    verb { 'be' }
  end
  factory :chronically_homeless, class: 'Rules::ChronicallyHomeless' do
    name { 'Chronically Homeless' }
    verb { 'be' }
  end
  factory :mental_health_eligible, class: 'Rules::MentalHealthEligible' do
    name { 'Mental Health Eligible' }
    verb { 'be' }
  end
  factory :homeless, class: 'Rules::Homeless' do
    name { 'Homeless' }
    verb { 'be' }
  end
  factory :mi_and_sa_co_morbid, class: 'Rules::MiAndSaCoMorbid' do
    name { 'Chronically homeless, mental health, and substance abuse' }
    verb { 'be' }
  end
  factory :mi_sa_or_co_morbid, class: 'Rules::MiSaOrCoMorbid' do
    name { 'Chronically homeless, mental health, or substance abuse' }
    verb { 'be' }
  end
  factory :physical_disability, class: 'Rules::PhysicalDisablingCondition' do
    name { 'Physically disabling condition' }
    verb { 'have' }
  end
  factory :income_less_than_30_percent_ami, class: 'Rules::IncomeLessThanThirtyPercentAmi' do
    name { 'Less than 30% Area Median Income (Very Low Income)' }
    verb { 'have' }
  end
  factory :income_less_than_50_percent_ami, class: 'Rules::IncomeLessThanFiftyPercentAmi' do
    name { 'Less than 50% Area Median Income (Very Low Income)' }
    verb { 'have' }
  end
  factory :income_less_than_60_percent_ami, class: 'Rules::IncomeLessThanSixtyPercentAmi' do
    name { 'Less than 60% Area Median Income (Very Low Income)' }
    verb { 'have' }
  end
  factory :low_income, class: 'Rules::IncomeLessThanEightyPercentAmi' do
    name { 'Less than 80% Area Median Income (Low Income)' }
    verb { 'have' }
  end
  factory :income, class: 'Rules::Income' do
    name { 'Income' }
    verb { 'have' }
  end
  factory :last_seen, class: 'Rules::SeenInLastThirtyDays' do
    name { 'Seen in Last 30 Days' }
    verb { 'be' }
  end
  factory :last_seen_90, class: 'Rules::SeenInLastNinetyDays' do
    name { 'Seen in Last 90 Days' }
    verb { 'be' }
  end
  factory :vispdat_less_than_3, class: 'Rules::VispdatScoreThreeOrLess' do
    name { 'VI-SPDAT score of 3 or less' }
    verb { 'have' }
  end
  factory :vispdat_less_than_4, class: 'Rules::VispdatScoreFourOrLess' do
    name { 'VI-SPDAT score of 4 or less' }
    verb { 'have' }
  end
  factory :vispdat_between_4_and_7, class: 'Rules::VispdatScoreFourToSeven' do
    name { 'VI-SPDAT score of 4 to 7' }
    verb { 'have' }
  end
  factory :vispdat_more_than_8, class: 'Rules::VispdatScoreEightOrMore' do
    name { 'VI-SPDAT score of 8 or more' }
    verb { 'have' }
  end
  factory :assessment_score_greater_than_0, class: 'Rules::AssessmentScoreGreaterThanZero' do
    name { 'Assessment Score greater than zero' }
    verb { 'have' }
  end
  factory :requires_ground_floor_unit, class: 'Rules::GroundFloor' do
    name { 'Ground floor unit' }
    verb { 'have' }
  end
  factory :wheelchair_accessible, class: 'Rules::Wheelchair' do
    name { 'Wheelchair accessible unit' }
    verb { 'have' }
  end
  factory :bedrooms_required, class: 'Rules::Bedroom' do
    name { 'Minimum number of bedrooms' }
    verb { 'have' }
  end
  factory :minimum_occupancy, class: 'Rules::Occupancy' do
    name { 'Minimum occupancy' }
    verb { 'have' }
  end
  factory :interested_in_neighborhood, class: 'Rules::InterestedInNeighborhood' do
    name { 'Interested in Neighborhood' }
    verb { 'be' }
  end
  factory :require_interest_in_neighborhood, class: 'Rules::RequireInterestInNeighborhood' do
    name { 'At least one neighborhood preference' }
    verb { 'have' }
  end
  factory :active_in_cohort, class: 'Rules::ActiveInCohort' do
    name { 'Active in Cohort' }
    verb { 'be' }
  end
  factory :tagged_with, class: 'Rules::TaggedWith' do
    name { 'Specified tag' }
    verb { 'have' }
  end
  factory :verified_days_homeless, class: 'Rules::VerifiedDaysHomeless' do
    name { 'Verified Days Homeless' }
    verb { "have" }
  end
  factory :interested_in_rrh, class: 'Rules::InterestedInRrh' do
    name { "Interested in RRH" }
    verb { "be" }
  end
  factory :interested_in_youth_rrh, class: 'Rules::InterestedInYouthRrh' do
    name { "Interested in Youth RRH" }
    verb { "be" }
  end
  factory :interested_in_dv_rrh, class: 'Rules::InterestedInDvRrh' do
    name { "Interested in DV RRH" }
    verb { "be" }
  end
  # factory :age_greater_than_eighteen, class: 'Rules::AgeGreaterThanEightteen' do
  #   name { "Age greater than 18" }
  #   verb { "be" }
  # end
  factory :age_greater_than_fifty, class: 'Rules::AgeGreaterThanFifty' do
    name { "Age greater than 50" }
    verb { "be" }
  end
  factory :age_greater_than_fifty_five, class: 'Rules::AgeGreaterThanFiftyFive' do
  name { "Age greater than 55" }
  verb { "be" }
  end
  factory :age_greater_than_forty_five, class: 'Rules::AgeGreaterThanFortyFive' do
    name { "Age greater than 45" }
    verb { "be" }
  end
  # factory :age_greater_than_sixteen, class: 'Rules::AgeGreaterThanSixteen' do
  #   name { "Age greater than 16" }
  #   verb { "be" }
  # end
  factory :age_greater_than_sixty, class: 'Rules::AgeGreaterThanSixty' do
    name { "Age greater than 60" }
    verb { "be" }
  end
  factory :age_greater_than_sixty_five, class: 'Rules::AgeGreaterThanSixtyFive' do
    name { "Age greater than 65" }
    verb { "be" }
  end
  factory :age_greater_than_sixty_two, class: 'Rules::AgeGreaterThanSixtyTwo' do
    name { "Age greater than 62" }
    verb { "be" }
  end
  # factory :age_greater_than_twenty_five, class: 'Rules::AgeGreaterThanTwentyFive' do
  #   name { "Age greater than 25" }
  #   verb { "be" }
  # end }
  factory :aids_or_related_diseases, class: 'Rules::AidsOrRelatedDiseases' do
    name { "AIDS or related diseases" }
    verb { "have" }
  end
  factory :appropriate_for_sober_supportive_housing, class: 'Rules::AppropriateForSoberSupportiveHousing' do
    name { "Appropriate for sober supportive housing" }
    verb { "be" }
  end
  factory :asylee, class: 'Rules::Asylee' do
    name { "An asylee" }
    verb { "be" }
  end
  factory :child_in_household, class: 'Rules::ChildInHousehold' do
    name { "Child in household" }
    verb { "have" }
  end
  factory :cspech_eligible, class: 'Rules::CspechEligible' do
    name { "CSPECH eligible" }
    verb { "be" }
  end
  factory :developmental_disability, class: 'Rules::DevelopmentalDisability' do
    name { "Developmental Disability" }
    verb { "have" }
  end
  factory :disabling_condition, class: 'Rules::DisablingCondition' do
    name { "Disabling Condition" }
    verb { "have" }
  end
  factory :dmh_eligible, class: 'Rules::DmhEligible' do
    name { "DMH Eligible" }
    verb { "be" }
  end
  factory :domestic_violence_survivor, class: 'Rules::DomesticViolenceSurvivor' do
    name { "Domestic Violence Survivor" }
    verb { "be" }
  end
  factory :elevator, class: 'Rules::Elevator' do
    name { "Elevator Access Need" }
    verb { "have" }
  end
  factory :enrolled_in_es, class: 'Rules::EnrolledInEs' do
    name { "Enrolled in ES" }
    verb { "be" }
  end
  factory :enrolled_in_hmis_project_a, class: 'Rules::EnrolledInHmisProject' do
    name { "Enrolled in HMIS Project" }
    verb { "be" }
  end
  factory :enrolled_in_sh, class: 'Rules::EnrolledInSh' do
    name { "Enrolled in SH" }
    verb { "be" }
  end
  factory :enrolled_in_so, class: 'Rules::EnrolledInSo' do
    name { "Enrolled in SO" }
    verb { "be" }
  end
  factory :enrolled_in_th, class: 'Rules::EnrolledInTh' do
    name { "Enrolled in TH" }
    verb { "be" }
  end
  factory :ground_floor, class: 'Rules::GroundFloor' do
    name { "Ground Floor Access Requirement" }
    verb { "have" }
  end
  factory :housing_authority_eligible, class: 'Rules::HousingAuthorityEligible' do
    name { "Housing Authority Eligible" }
    verb { "be" }
  end
  factory :hues_eligible, class: 'Rules::HuesEligible' do
    name { "HUES Eligible" }
    verb { "be" }
  end
  factory :ineligible_immigrant, class: 'Rules::IneligibleImmigrant' do
    name { "An Ineligible Immigrant" }
    verb { "be" }
  end
  factory :lifetime_sex_offender, class: 'Rules::LifetimeSexOffender' do
    name { "A Lifetime Sex Offender" }
    verb { "be" }
  end
  factory :meth_production_conviction, class: 'Rules::MethProductionConviction' do
    name { "Meth Production Conviction" }
    verb { "have" }
  end
  factory :one_eighty_days_homeless, class: 'Rules::OneEightyDaysHomeless' do
    name { "Homeless 180 days" }
    verb { "be" }
  end
  factory :two_seventy_days_homeless, class: 'Rules::TwoSeventyDaysHomeless' do
    name { "Homeless 270 days" }
    verb { "be" }
  end
  factory :one_year_homeless, class: 'Rules::OneYearHomeless' do
    name { "Homeless 365 days" }
    verb { "be" }
  end
  factory :one_eighty_days_homeless_last_three_years, class: 'Rules::OneEightyDaysHomelessLastThreeYears' do
   name { "Homeless 180 days in the last three years" }
    verb { "be" }
  end
  factory :two_seventy_days_homeless_last_three_years, class: 'Rules::TwoSeventyDaysHomelessLastThreeYears' do
    name { "Homeless 270 days in the last three years" }
    verb { "be" }
  end
  factory :one_year_homeless_last_three_years, class: 'Rules::OneYearHomelessLastThreeYears' do
    name { "Homeless 365 days in the last three years" }
    verb { "be" }
  end
  factory :part_of_a_family, class: 'Rules::PartOfAFamily' do
    name { "Part of a Family" }
    verb { "be" }
  end
  factory :ssvf_eligible, class: 'Rules::SsvfEligible' do
    name { "SSVF Eligible" }
    verb { "be" }
  end
  factory :us_citizen, class: 'Rules::UsCitizen' do
    name { "US Citizen" }
    verb { "be" }
  end
  factory :va_eligible, class: 'Rules::VaEligible' do
    name { "VA Eligible" }
    verb { "be" }
  end
  factory :verified_disability, class: 'Rules::VerifiedDisability' do
    name { "Verified Disability" }
    verb { "have" }
  end
  factory :transgender, class: 'Rules::Transgender' do
    name { "Transgender" }
    verb { "be" }
  end
  factory :willing_to_live_in_congregate_housing, class: "Rules::WillingToLiveInCongregateHousing" do
    name { "Willing to live in congregate housing" }
    verb { "be" }
  end
  factory :interested_in_set_asides, class: "Rules::InterestedInSetAsides" do
    name { "Interested in set-asides" }
    verb { "be" }
  end
  factory :vash_eligible, class: "Rules::VashEligible" do
    name { "VASH Eligibile" }
    verb { "be" }
  end
  factory :pregnant, class: "Rules::Pregnant" do
    name { "Pregnant" }
    verb { "be" }
  end
  factory :sro_ok, class: "Rules::SroOk" do
    name { "Ok wih SRO" }
    verb { "be" }
  end
  factory :evicted, class: "Rules::NeverEvicted" do
    name { "Never been evicted" }
    verb { "have" }
  end
  factory :pathways_eligible, class: "Rules::PathwaysEligible" do
    name { "a pathways assessment newer than most recent ineligible decline" }
    verb { "have" }
  end
  factory :rank_below, class: "Rules::RankBelow" do
    name { "Rank Higher (closer to #1) than" }
    verb { "have" }
  end
end

