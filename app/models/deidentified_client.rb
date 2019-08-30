###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class DeidentifiedClient < NonHmisClient
  validates :client_identifier, uniqueness: true

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
      assessment_score,
      agency&.name,
      cohort_names,
      date_of_birth,
      ssn,
      days_homeless_in_the_last_three_years,
      veteran,
      rrh_desired,
      youth_rrh_desired,
      rrh_assessment_contact_info,
      income_maximization_assistance_requested,
      pending_subsidized_housing_placement,
      full_release_on_file,
      requires_wheelchair_accessibility,
      required_number_of_bedrooms,
      required_minimum_occupancy,
      requires_elevator_access,
      family_member,
      calculated_chronic_homelessness,
      gender,
      date_days_homeless_verified,
      who_verified_days_homeless,
      income_total_monthly,
      disabling_condition,
      physical_disability,
      developmental_disability,
      domestic_violence,
      created_at,
      updated_at,
    ]
  end

  def client_scope
    DeidentifiedClient.all
  end
end
