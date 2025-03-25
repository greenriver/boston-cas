###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module TcHatCalculations
  extend ActiveSupport::Concern

  included do
    after_initialize :set_defaults
    validates_presence_of :entry_date, :hud_assessment_location, :hud_assessment_type, :tc_hat_assessment_level, on: [:create, :update]

    private def set_defaults
      return if persisted?

      self.actively_homeless = true
      self.tc_hat_assessment_level = 2
    end

    def hud_assessment_level
      tc_hat_assessment_level
    end

    def calculated_score
      days_homeless
    end

    def assessment_score
      days_homeless
    end

    def rrh_desired
      full_time_employed || rrh_successful_exit
    end

    # Fake the dob of the client within the given age range
    def date_of_birth
      return unless hoh_age.present?

      range = age_ranges.dig(hoh_age, :range)
      return unless range.present?

      fuzz = -50..50
      value = rand(range)
      if value == range.first
        # When value is the first year in the range, we only want to SUBTRACT days
        # This will ensure the age is at least the minimum age in the range.
        # e.g. running on Jan 1, 2025, 17 years ago would be 2008-01-01. If we add
        # 50 days, the dob would be 2008-02-20 which would make the client 16 years old.
        # If we subtracting 50 days would make the date 2007-11-30 which would make the
        # client's age 17 years.
        fuzz = -50..-1
      elsif value == range.last
        # Do the opposite of the above for the other end of the range
        fuzz = 1..50
      end
      value.years.ago.to_date + rand(fuzz).days
    end

    private def age_ranges
      {
        nil => {
          range: -2..-1,
          label: 'Unknown age',
        },
        '17' => {
          range: 12..17,
          label: 'less than 17',
        },
        '18' => {
          range: 18..24,
          label: '18 - 24',
        },
        '25' => {
          range: 25..30,
          label: '25 - 30',
        },
        '31' => {
          range: 31..40,
          label: '31 - 40',
        },
        '41' => {
          range: 41..50,
          label: '41 - 50',
        },
        '51' => {
          range: 51..54,
          label: '51 - 54',
        },
        '55' => {
          range: 55..59,
          label: '55 - 59',
        },
        '60' => {
          range: 60..61,
          label: '60 - 61',
        },
        '62' => {
          range: 62..90,
          label: '62 or older',
        },
      }
    end

    def ages
      age_ranges.map { |age, data| [data[:label], age] }.to_h
    end

    # Override required_number_of_bedrooms since the TC HAT doesn't currently ask it
    def required_number_of_bedrooms
      num = 1
      num = 2 if tc_hat_single_parent_child_over_ten

      num = case household_size
      # when 1, 2 # unnecessary, these would result in 1 bedroom
      when 3, 4
        2
      when 5, 6
        3
      when 7, 8
        4
      when 9, 10
        5
      when (11..)
        6
      else
        num
      end
      num
    end

    def required_minimum_occupancy
      household_size
    end

    # Override family_member since the TC HAT doesn't currently ask it
    def family_member
      # Pregnant clients are always considered a family
      return true if pregnancy_status
      # There is a child, but the parent doesn't, and won't have custody
      return false if tc_hat_single_parent_child_over_ten && (!tc_hat_legal_custody && !tc_hat_will_gain_legal_custody)
      # Client indicated the household is adult only
      return false unless tc_hat_household_type.in?(['Adults with Children', 'Youth'])
      return true if household_size.present? && household_size > 1
      # If the client failed to count the child, but will have custody at some point,
      # still consider this a family
      return true if household_size == 1 && (tc_hat_legal_custody || tc_hat_will_gain_legal_custody)

      false
    end

    def child_in_household
      return tc_hat_household_type == 'Adults with Children'
    end

    def client_history_options
      {
        partner_violence_survivor: 'Survivor of Intimate Partner Violence',
        dv_survivor: 'Survivor of family violence, sexual violence, or sex trafficking',
        unsheltered: 'Currently unsheltered or living in a place unfit for human habitation',
        n_a: 'N/A (None of these apply)',
      }.transform_keys(&:to_s)
    end

    def housing_preference_options
      {
        apartment: 'Apartment',
        accessible: 'Handicap Accessible',
        house: 'House',
        near_outdoors: 'Near outdoor spaces like parks, trails, and playgrounds',
        public_transit: 'Near Public Transportation',
        no_preference: 'No Preference',
        pets_allowed: 'Pets Allowed',
        with_formerly_homeless: 'Prefer to live in a community with others who are formerly homeless?',
        quiet: 'Quiet Neighborhood',
        roomate: 'Roommate',
        rv: 'RV',
        tiny_home: 'Tiny home',
      }.transform_keys(&:to_s)
    end

    def housing_rejection_preference_options
      {
        apartment: 'Apartment',
        accessible: 'Handicap Accessible',
        house: 'House',
        near_outdoors: 'Near outdoor spaces like parks, trails, and playgrounds',
        public_transit: 'Near Public Transportation',
        no_preference: 'No Preference',
        pets_allowed: 'Pets Allowed',
        quiet: 'Quiet Neighborhood',
        roomate: 'Roommate',
        rv: 'RV',
        tiny_home: 'Tiny home',
      }.transform_keys(&:to_s)
    end

    def available_housing_ranks
      @available_housing_ranks ||= (1..5).to_a.map { |i| [i, i] }.to_h
    end

    def form_fields
      {
        _section_a_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_a_preamble',
        },
        entry_date: {
          label: 'Date of Assessment',
          as: :date_picker,
          required: true,
          number: 'A-1',
        },
        hud_assessment_location: {
          label: 'Assessment Location',
          as: :select_2,
          collection: hud_assessment_locations,
          required: true,
          number: 'A-2',
        },
        hud_assessment_type: {
          label: 'Assessment Type',
          as: :select_2,
          collection: hud_assessment_types,
          required: true,
          number: 'A-3',
        },
        tc_hat_assessment_level: {
          label: 'Assessment Level',
          collection: {
            'Crisis Needs Assessment' => 1,
            'Housing Needs Assessment' => 2,
          },
          as: :pretty_boolean_group,
          number: 'A-4',
        },
        _tc_hat_placed_on_list_note: {
          label: 'Prioritization Status',
          number: 'A-5',
          description: 'Placed on prioritization list',
        },
        tc_hat_household_type: {
          label: 'Household Type',
          collection: {
            'Single Adult Only' => 'Single Adult Only',
            '2+ Adults Only (no minors)' => 'Adults Only',
            'Family (including minor children)' => 'Adults with Children',
            'Youth (age 18-24)' => 'Youth',
          },
          as: :pretty_boolean_group,
          number: 'A-6',
        },
        tc_hat_single_parent_child_over_ten: {
          label: 'Are you a single parent with a child over the age of 10?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'A-7',
        },
        household_size: {
          label: 'How many household members (including minor children) do you expect to live with you when you\'re housed?',
          number: 'A-8',
        },
        tc_hat_legal_custody: {
          label: 'Do you have legal custody of your children? (This includes shared custody.)',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'A-9',
        },
        tc_hat_will_gain_legal_custody: {
          label: 'If you do not have legal custody of your children, will you gain custody of the children when you are housed?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'A-10',
        },
        veteran: {
          label: 'Is the client a Veteran?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'A-14',
        },
        days_homeless: {
          label: 'Total Days Experiencing Literal Homelessness or Fleeing Unsafe Situations',
          number: 'A-15',
          description: 'How many instances of homelessness has the client experienced in the past 3 years? This can include situations where the client has had to leave their home due to domestic violence (DV), intimate partner violence (IPV), sexual assault (SA), trafficking, or other related circumstances. They could have stayed with a friend, family, stayed in their car, or went to a shelter. You may start the calculation from when the client either first attempted to flee, even if it was not successful, started or attempted to start working with a Victim Service Provider (VSP). Include any literal homeless time and add this time together for cumulative days homeless.',
        },
        calculated_chronic_homelessness: {
          label: 'Permanent Supportive Housing Eligible',
          collection: {
            'Yes' => 1,
            'No' => 0,
          },
          as: :pretty_boolean_group,
          number: 'A-16',
          description: 'For PSH eligibility the client must have TWO COMPONENTS

  1. The client must have 12 consecutive months of literal homelessness from today’s date back OR 4 or more episodes of literal homelessness in the last 3 years that adds up to 12 months with at least 7 days between each episode.
  2. Disabling Condition Length of Homelessness Physical, mental, or emotional impairment which is expected to be of long continued and indefinite duration; substantially impedes his or her ability to live independently and is of such nature that such ability could be improved by more suitable housing conditions. This is proven with either a VOD (Form is Provided by Partnership Homes and is completed by client and a Provider).',
        },
        hoh_age: {
          label: 'Age of the Head of Household',
          number: 'A-17',
          as: :pretty_boolean_group,
          collection: ages,
        },
        _section_b_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_b_preamble',
        },
        _strengths_and_challenges_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/strengths_and_challenges_preamble',
        },
        strengths: {
          label: 'Strengths (Check all that apply.)',
          collection: Rules::Strength.new.available_strengths.to_h.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
          number: 'B-1',
        },
        challenges: {
          label: 'Possible challenges for housing placement options (Check all that apply)',
          collection: Rules::Challenge.new.available_challenges.to_h.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
          number: 'B-2',
        },
        lifetime_sex_offender: {
          label: 'Is the client a Lifetime Sex Offender?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-3',
        },
        state_id: {
          label: 'Does the client have a State ID/Drivers License?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-4',
        },
        birth_certificate: {
          label: 'Does the client have a Birth Certificate?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-5',
        },
        social_security_card: {
          label: 'Does the client have a Social Security Card?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-6',
        },
        _documents_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/documents_preamble',
        },
        has_tax_id: {
          label: 'Do you or have you had (in the past) an I-9 or an ITIN (Individual Tax Identification Number)?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-7',
        },
        tax_id: {
          label: 'What was/is your I-9 or ITIN number?',
          number: 'B-8',
        },
        _section_c_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_c_preamble',
        },
        _medium_term_rental_assistance_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/medium_term_rental_assistance_preamble',
        },
        rrh_successful_exit: {
          label: '[STAFF RESPONSE] I believe the client can successfully exit 12-24 month RRH Program and maintain their housing.',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-5',
        },
        _th_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/th_preamble',
        },
        th_desired: {
          label: '[CLIENT RESPONSE] Are you interested in Transitional Housing?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-6',
        },
        _section_d_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_d_preamble',
        },
        _long_term_rental_assistance_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/long_term_rental_assistance_preamble',
        },
        disabling_condition: {
          label: 'Does the Client have a disabling condition?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-1',
        },
        mental_health_problem: {
          label: 'Does the Client have a mental health disorder?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-2',
        },
        substance_abuse_problem: {
          label: 'Does the Client have a substance use disorder?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-3',
        },
        physical_disability: {
          label: 'Does the Client have a physical disability?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-4',
        },
        _section_e_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_e_preamble',
        },
        _client_history_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/client_history_preamble',
        },
        tc_hat_client_history: {
          label: 'Client History (Check all that apply):',
          collection: client_history_options.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
          number: 'E-1',
        },
        pregnancy_status: {
          label: 'Are you currently pregnant?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-9',
        },
        pregnant_under_28_weeks: {
          label: 'If pregnant, is this your first pregnancy AND are you under 28 weeks in the course of the pregnancy?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-10',
        },
        open_case: {
          label: 'Current open case with State Dept. of Family Services (CPS)?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-11',
        },
        foster_care: {
          label: 'Was in foster care as a youth, at age 16 years or older?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-12',
        },
        currently_fleeing: {
          label: '[CLIENT RESPONSE] You indicated a history of Intimate Partner Violence (IPV). Are you currently fleeing?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-13',
        },
        dv_date: {
          label: '[CLIENT RESPONSE] You indicated a history of Intimate Partner Violence (IPV). What was the most recent date the violence occurred? (This can be an estimated date)',
          as: :date_picker,
          number: 'E-14',
        },
        hiv_aids: {
          label: 'Does the client have HIV or AIDS?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-21',
        },
        _section_f_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_f_preamble',
        },
        _housing_preferences_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/housing_preferences_preamble',
        },
        neighborhood_interests: {
          label: 'Housing Location Preference',
          collection: Neighborhood.for_select,
          as: :pretty_checkboxes_group,
          number: 'F-3',
        },
        notes: {
          label: 'Client Note',
          number: 'F-12',
        },
        actively_homeless: {
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'F-14',
        },
      }
    end
  end
end
