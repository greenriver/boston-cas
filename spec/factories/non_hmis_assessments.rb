# frozen_string_literal: true

FactoryBot.define do
  factory :non_hmis_assessment do
    association :non_hmis_client
    association :agency
    entry_date { Date.today }
    type { 'DeidentifiedCovidPathwaysAssessment' }

    trait :limitable_pathway do
      type { NonHmisAssessment.limited_assessment_types.sample }
    end

    trait :non_limitable_pathway do
      type { 'SomeOtherAssessmentType' } # A placeholder for a non-limitable type
    end
  end
end
