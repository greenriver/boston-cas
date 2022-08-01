###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

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

    def client_history_options
      {
        tc_hat_ed_visits: 'Four or more trips to the Emergency Room in the past year',
        psychiatric_facility: 'One or more stays in a psychiatric facility (lifetime)',
        jail_stay: 'One or more stays in prison/jail/correctional facility (lifetime)',
        substance_use_facility: 'One or more stays in a substance abuse treatment facility (lifetime)',
        nursing_home: 'One or more stays in another type of residential facility (including a nursing home or group home)(lifetime)',
        youth_homelessness: 'Had one or more experiences of homelessness before the age of 25 (adults in house)',
        no_cash: 'No earned income (from employment) during the past year',
        partner_violence_survivor: 'Survivor of Intimate Partner Violence',
        dv_survivor: 'Survivor of family violence, sexual violence, or sex trafficking',
        unsheltered: 'Currently unsheltered or living in a place unfit for human habitation',
        household_chronic_health_condition: 'Household member living with a chronic health condition that is disabling',
        acute_care_need: 'Acute care need (e.g., severe infection, acute diabetic condition, mental health crisis)',
        development_disorder: 'Intellectual/Developmental Disorder (IDD)',
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
        tc_hat_household_type: {
          label: 'Household Type',
          collection: {
            '2+ Adults Only (no minors)' => 'Adults Only',
            'Family (including minor children)' => 'Adults with Children',
            'Single Adult Only' => 'Single Adult Only',
            'Youth (age 18-24)' => 'Youth',
          },
          as: :pretty_boolean_group,
          number: 'A-5',
        },
        need_daily_assistance: {
          label: '[STAFF RESPONSE] Only check this box if you feel the client is unable to live alone due to needing around the clock care or that they may be dangerous/harmful to themselves or their neighbors without ongoing support. (If unknown, you may skip this question.)',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          number: 'A-6',
        },
        _needs_daily_assistance_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/needs_daily_assistance_preamble',
        },
        ongoing_support_reason: {
          label: '[STAFF RESPONSE] Explain why this client cannot live independently',
          question_wrapper: { class: 'jDailyAssistance' },
          number: 'A-7',
        },
        ongoing_support_housing_type: {
          label: '[STAFF RESPONSE] What type of housing intervention would be more suitable for this client, if known?',
          collection: {
            'Group Home' => 'Group Home',
            'Nursing Home' => 'Nursing Home',
            'Safe Haven' => 'Safe Haven',
            'Simon (residential services for homeless people who have been dually-diagnosed with a co-occurring disorder of mental illness and drug/alcohol addiction' => 'Simon',
            'State Mental Health Institution' => 'State Mental Health Institution',
          },
          as: :pretty_boolean_group,
          number: 'A-8',
        },
        veteran: {
          label: 'Is the client a Veteran?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'A-9',
        },
        days_homeless: {
          label: 'Cumulative Days Homeless',
          number: 'A-10',
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
        roommate_ok: {
          label: 'Would you consider living with a roommate?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'B-9',
        },
        _section_c_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_c_preamble',
        },
        _medium_term_rental_assistance_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/medium_term_rental_assistance_preamble',
        },
        full_time_employed: {
          label: '[CLIENT RESPONSE] Are you currently working a full time job?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-1',
        },
        can_work_full_time: {
          label: '[STAFF RESPONSE] Is the client able to work a full-time job?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-2',
        },
        willing_to_work_full_time: {
          label: '[STAFF RESPONSE] Is the client willing to work a full-time?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-3',
        },
        why_not_working: {
          label: '[CLIENT RESPONSE] If you can work and are willing to work a full time job, why are you not working right now?',
          number: 'C-4',
          as: :text,
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
        _th_questions_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/th_questions_preamble',
        },
        drug_test: {
          label: '[CLIENT RESPONSE] Can you pass a drug test?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-7',
        },
        heavy_drug_use: {
          label: '[CLIENT RESPONSE] Do you have a history of heavy drug use? (Use that has affected your ability to work and/or maintain housing?)',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-8',
        },
        sober: {
          label: '[CLIENT RESPONSE] Have you been clean/sober for at least one year?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-9',
        },
        willing_case_management: {
          label: '[CLIENT RESPONSE] Are you willing to engage with housing case management? (Would you participate in a program, goal setting, etc.?)',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-10',
        },
        employed_three_months: {
          label: '[CLIENT RESPONSE] Have you been employed for 3 months or more?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-11',
        },
        living_wage: {
          label: '[CLIENT RESPONSE] Are you earning $13 an hour or more?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'C-12',
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
          label: '[STAFF RESPONSE] Does the client have a disability that is expected to be long-term, and substantially impairs their ability to live independently over time (as indicated in the HUD assessment)?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-1',
        },
        site_case_management_required: {
          label: '[STAFF RESPONSE] Does the client need site-based case management? (This is NOT skilled nursing, group home, or assisted living care.)',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'D-2',
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
        jail_caused_episode: {
          label: 'You have indicated your client has had one or more stays in prison/jail/correctional facility in their lifetime.  Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-2',
        },
        income_caused_episode: {
          label: 'You have indicated your client has had NO earned income from employment during the past year. Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-3',
        },
        ipv_caused_episode: {
          label: 'You have indicated your client is a survivor of Intimate Partner Violence. Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-4',
        },
        violence_caused_episode: {
          label: 'You have indicated your client is a survivor of family violence, sexual violence, or sex trafficking. Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-5',
        },
        chronic_health_caused_episode: {
          label: 'You have indicated that a household member is living with a chronic health condition that is disabling.  Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-6',
        },
        acute_health_caused_episode: {
          label: 'You have indicated that the client has an acute health care need. Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-7',
        },
        idd_caused_episode: {
          label: 'You have indicated that the client has an Intellectual/Developmental Disorder (IDD). Did this cause their current episode of homelessness?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-8',
        },
        pregnant: {
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
        tc_hat_ed_visits: {
          label: 'Has the client had more than 3 hospitalizations or emergency room visits in a year?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-15',
        },
        # tc_hat_hospitalizations: {
        #   label: 'More than three hospitalization or emergency room visits in a year?',
        #   collection: {
        #     'Yes' => true,
        #     'No' => false,
        #   },
        #   as: :pretty_boolean_group,
        #   number: 'E-7',
        # },
        sixty_plus: {
          label: 'Is the client 60 years old or older?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-16',
        },
        cirrhosis: {
          label: 'Does the client have cirrhosis of the liver?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-17',
        },
        end_stage_renal_disease: {
          label: 'Does the client have end stage renal disease?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-18',
        },
        heat_stroke: {
          label: 'Does the client have a history of Heat Stroke?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-19',
        },
        blind: {
          label: 'Is the client blind?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-20',
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
        tri_morbidity: {
          label: 'Does the client have "tri-morbidity" (co-occurring psychiatric, substance abuse, and a chronic medical condition)?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-22',
        },
        high_potential_for_victimization: {
          label: 'Is there a high potential for victimization?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-23',
        },
        self_harm: {
          label: 'Is there a danger of self harm or harm to other person in the community?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-24',
        },
        medical_condition: {
          label: 'Does the client have a chronic or acute medical condition?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-25',
        },
        psychiatric_condition: {
          label: 'Does the client have a chronic or acute psychiatric condition with extreme lack of judgement regarding safety?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-26',
        },
        substance_abuse_problem: {
          label: 'Does the client have a chronic or acute substance abuse with extreme lack of judgment regarding safety?',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
          number: 'E-27',
        },
        assessment_score: {
          label: 'Total Vulnerability Score',
          number: 'E-28',
        },
        _section_f_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/section_f_preamble',
        },
        _housing_preferences_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/housing_preferences_preamble',
        },
        housing_preferences: {
          label: 'Housing Preference (Check all that apply.)',
          collection: housing_preference_options.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
          number: 'F-1',
        },
        housing_preferences_other: {
          label: 'Housing Preference if other',
          number: 'F-2',
        },
        neighborhood_interests: {
          label: 'Housing Location Preference',
          collection: Neighborhood.for_select,
          as: :pretty_checkboxes_group,
          number: 'F-3',
        },
        _housing_rank_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/housing_rank_preamble',
        },
        tc_hat_apartment: {
          label: 'Apartment',
          collection: available_housing_ranks,
          as: :select_2,
          include_blank: 'Please Choose Rank',
          number: 'F-6',
        },
        tc_hat_tiny_home: {
          label: 'Tiny Home',
          collection: available_housing_ranks,
          as: :select_2,
          include_blank: 'Please Choose Rank',
          number: 'F-7',
        },
        tc_hat_rv: {
          label: 'RV/Camper',
          collection: available_housing_ranks,
          as: :select_2,
          include_blank: 'Please Choose Rank',
          number: 'F-8',
        },
        tc_hat_house: {
          label: 'House',
          collection: available_housing_ranks,
          as: :select_2,
          include_blank: 'Please Choose Rank',
          number: 'F-9',
        },
        tc_hat_mobile_home: {
          label: 'Mobile Home/Manufactured Home',
          collection: available_housing_ranks,
          as: :select_2,
          include_blank: 'Please Choose Rank',
          number: 'F-10',
        },
        housing_rejected_preferences: {
          label: 'Which housing would you not like to live in?',
          collection: housing_rejection_preference_options.invert,
          as: :pretty_checkboxes_group,
          number: 'F-11',
        },
        notes: {
          label: 'Client Note',
          number: 'F-12',
        },
        hoh_age: {
          label: 'Age',
          number: 'F-13',
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
