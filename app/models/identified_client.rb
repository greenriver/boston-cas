class IdentifiedClient < NonHmisClient
  # Allow same search rules as Client
  scope :text_search, lambda { |text|
    return none unless text.present?

    text.strip!
    sa = arel_table
    numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = %r{\d\d/\d\d/\d\d\d\d}.match(text).try(:[], 0) == text
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
      where = search_first_name(first).
        and(search_last_name(last)).
        or(search_alternate_name(first)).
        or(search_alternate_name(last))
      # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.delete('-'))
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
  }

  def download_headers
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
      _('Part of a family'),
      _('Chronically homeless family'),
      'Gender',
      _('Date days homeless verified'),
      'Who verified days homeless',
      'Total monthly income',
      'Disabling condition',
      'Physical disability',
      'Developmental disability',
      'Domestic violence survivor',
    ]
  end

  def download_data
    [
      id,
      first_name,
      middle_name,
      last_name,
      assessment_score,
      agency,
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
    ]
  end
end
