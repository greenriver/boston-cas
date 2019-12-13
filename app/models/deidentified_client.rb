###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class DeidentifiedClient < NonHmisClient
  validates :client_identifier, uniqueness: true
  has_many :client_assessments, class_name: 'DeidentifiedClientAssessment', foreign_key: :non_hmis_client_id, dependent: :destroy
  accepts_nested_attributes_for :client_assessments

  # Search only the client identifier
  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    where(search_alternate_name(text))
  end

  def download_headers
    [
      "id",
      "Client Identifier",
      "First Name",
      "Middle name",
      "Last Name",
      "Assessment Score",
      "VI-SPDAT Score",
      "VI-SPDAT Priority Score",
      "Agency",
      "Active Cohorts",
      "DOB",
      "SSN",
      "Days homeless in the last three years",
      "Veteran",
      'Interested in RRH',
      'Interested in Youth RRH',
      'Client and/or Case Manager Contact Information',
      "Income maximization assistance requested",
      "Pending subsidized housing placement",
      "Full release on file",
      "Requires wheelchair accessibility",
      "Required number of bedrooms",
      "Required minimum occupancy",
      "Requires elevator access",
      _('Part of a family'),
      _('Chronically homeless family'),
      "Gender",
      _("Date days homeless verified"),
      "Who verified days homeless",
      "Total monthly income",
      "Disabling condition",
      "Physical disability",
      "Developmental disability",
      "Domestic violence survivor",
      "Created",
      "Last Update",
    ]
  end

  def download_data
    [
      id,
      client_identifier,
      first_name,
      middle_name,
      last_name,
      current_assessment.assessment_score,
      current_assessment.vispdat_score,
      current_assessment.vispdat_priority_score,
      agency&.name,
      cohort_names,
      date_of_birth,
      ssn,
      current_assessment.days_homeless_in_the_last_three_years,
      current_assessment.veteran,
      current_assessment.rrh_desired,
      current_assessment.youth_rrh_desired,
      current_assessment.rrh_assessment_contact_info,
      current_assessment.income_maximization_assistance_requested,
      current_assessment.pending_subsidized_housing_placement,
      full_release_on_file,
      current_assessment.requires_wheelchair_accessibility,
      current_assessment.required_number_of_bedrooms,
      current_assessment.required_minimum_occupancy,
      current_assessment.requires_elevator_access,
      current_assessment.family_member,
      current_assessment.calculated_chronic_homelessness,
      gender,
      current_assessment.date_days_homeless_verified,
      current_assessment.who_verified_days_homeless,
      current_assessment.income_total_monthly,
      current_assessment.disabling_condition,
      current_assessment.physical_disability,
      current_assessment.developmental_disability,
      current_assessment.domestic_violence,
      created_at,
      current_assessment.updated_at,
    ]
  end

  def client_scope
    DeidentifiedClient.all
  end
end
