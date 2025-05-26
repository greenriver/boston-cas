# frozen_string_literal: true

FactoryBot.define do
  factory :non_hmis_assessment do
    association :non_hmis_client
    association :agency
    entry_date { Date.today }
    # Add other default attributes as necessary, e.g., type
    # For testing 'limitable_pathways', we might need specific types.
    # NonHmisAssessment.limited_assessment_types returns:
    # ["DeidentifiedCovidPathwaysAssessment", "IdentifiedCovidPathwaysAssessment",
    #  "DeidentifiedPathwaysVersionThree", "IdentifiedPathwaysVersionThree",
    #  "DeidentifiedPathwaysVersionFour", "IdentifiedPathwaysVersionFour"]
    # Let's default to one of these for now, or allow it to be passed.
    type { 'DeidentifiedCovidPathwaysAssessment' }

    trait :limitable_pathway do
      type { NonHmisAssessment.limited_assessment_types.sample }
    end

    trait :non_limitable_pathway do
      type { 'SomeOtherAssessmentType' } # A placeholder for a non-limitable type
    end
  end
end
