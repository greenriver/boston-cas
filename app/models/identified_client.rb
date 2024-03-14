###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class IdentifiedClient < NonHmisClient
  has_many :client_assessments, class_name: 'IdentifiedClientAssessment', foreign_key: :non_hmis_client_id, dependent: :destroy
  accepts_nested_attributes_for :client_assessments

  alias gender genders
  alias race races

  # Allow same search rules as Client
  scope :text_search, -> (text) do
    return none unless text.present?
    text.strip!
    sa = arel_table
    numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = /\d\d\/\d\d\/\d\d\d\d/.match(text).try(:[], 0) == text
    social = /\d\d\d-\d\d-\d\d\d\d/.match(text).try(:[], 0) == text
    # Explicitly search for only last, first if there's a comma in the search
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
      if last.present?
        where = search_last_name(last).or(search_alternate_name(last))
      end
      if last.present? && first.present?
        where = where.and(search_first_name(first)).or(search_alternate_name(first))
      elsif first.present?
        where = search_first_name(first).or(search_alternate_name(first))
      end
      # Explicity search for "first last"
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
      where = search_first_name(first)
          .and(search_last_name(last))
          .or(search_alternate_name(first))
          .or(search_alternate_name(last))
      # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.gsub('-', ''))
    elsif date
      (month, day, year) = text.split('/')
      where = sa[:date_of_birth].eq("#{year}-#{month}-#{day}")
    else
      query = "%#{text}%"
      where = search_first_name(text).
        or(search_last_name(text)).
        or(sa[:ssn].matches(query)).
        or(search_alternate_name(text))
    end
    where(where)
  end

  def editable_by?(user)
    return true if user.can_manage_identified_clients?
    return true if pathways_enabled? && user.can_enter_identified_clients?
    return user.agency_id == agency_id if user.can_enter_identified_clients?

    false
  end

  def can_see_assessment_score?(user)
    user.can_manage_identified_clients? || Config.get(:identified_client_assessment) != 'IdentifiedCovidPathwaysAssessment'
  end

  def assessment_type
    self.class.assessment_type
  end

  def self.assessment_type
    Config.get(:identified_client_assessment) || 'IdentifiedClientAssessment'
  end

  def download_headers
    if pathways_enabled?
      [
        'id',
        'First Name',
        'Middle name',
        'Last Name',
        'DOB',
        'Gender',
        'Race',
        'Ethnicity',
        'SSN',
        'Agency',
        'Assessment Score',
        'Assessment Date',
      ] + Config.get(:identified_client_assessment).constantize.new.form_field_labels
    else
      [
        'id',
        'First Name',
        'Middle name',
        'Last Name',
        'Assessment Score',
        'Agency',
        'Active Cohorts',
        'DOB',
        'SSN',
        'Days homeless in the last three years',
        'Veteran',
        'Interested in RRH',
        'Interested in Youth RRH',
        'Client and/or Case Manager Contact Information',
        'Income maximization assistance requested',
        'Pending subsidized housing placement',
        'Full release on file',
        'Requires wheelchair accessibility',
        'Required number of bedrooms',
        'Required minimum occupancy',
        'Requires elevator access',
        Translation.translate('Part of a family'),
        Translation.translate('Chronically homeless family'),
        'Gender',
        Translation.translate('Date days homeless verified'),
        'Who verified days homeless',
        'Total monthly income',
        'Disabling condition',
        'Physical disability',
        'Developmental disability',
        'Domestic violence survivor',
        'Created',
        'Last Update',
      ]
    end
  end

  def download_data
    if pathways_enabled?
      [
        id,
        first_name,
        middle_name,
        last_name,
        date_of_birth,
        gender_descriptions.join(', '),
        race_descriptions.join(', '),
        Ethnicity.find_by(numeric: ethnicity)&.text,
        ssn,
        agency&.name,
        current_assessment&.assessment_score,
        current_assessment&.updated_at,
      ] + (current_assessment&.form_field_values || [])
    else
      [
        id,
        first_name,
        middle_name,
        last_name,
        current_assessment.assessment_score,
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
        gender_descriptions.join(', '),
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
  end

  def client_scope
    IdentifiedClient.all
  end
end
