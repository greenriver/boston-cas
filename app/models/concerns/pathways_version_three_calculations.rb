###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module PathwaysVersionThreeCalculations
  extend ActiveSupport::Concern

  included do
    def title
      assessment_type_options[assessment_type.to_sym][:title]
    end

    def pathways_assessment_type
      :pathways_2021
    end

    def transfer_assessment_type
      :transfer_assessment
    end

    def pathways_title
      'Pathways 2021'
    end

    def transfer_title
      'Transfer Assessment'
    end

    def pathways_description
      _('We want to reach a you when there is a housing program opening for you.')
    end

    def transfer_description
      _('Gather information about a rapid re-housing (RRH) participant’s housing stability.')
    end

    def assessment_type_options
      {
        pathways_assessment_type => { title: pathways_title, description: pathways_description },
        transfer_assessment_type => { title: transfer_title, description: transfer_description },
      }
    end

    def requires_assessment_type_choice?
      true
    end

    def calculated_score
      return 70 if pending_subsidized_housing_placement

      score = 0
      score += 20 if documented_disability
      score += 20 if health_prioritized
      needs = Array.wrap(medical_care_last_six_months).reject(&:blank?) + Array.wrap(service_need_indicators)&.reject(&:blank?) + Array.wrap(intensive_needs).reject(&:blank?)
      score += 12 if needs.any?(&:present?) || intensive_needs_other.present?

      case homeless_night_range
      when 'Fleeing Domestic Violence (no range needed)', '365+ Boston homeless nights in the last three years'
        score += 10
      when '30-60 Boston homeless nights in the last three years'
        score += 1
      when '61-90 Boston homeless nights in the last three years'
        score += 2
      when '91-120 Boston homeless nights in the last three years'
        score += 3
      when '121-150 Boston homeless nights in the last three years'
        score += 4
      when '151-180 Boston homeless nights in the last three years'
        score += 5
      when '181-210 Boston homeless nights in the last three years'
        score += 6
      when '211-240 Boston homeless nights in the last three years'
        score += 7
      when '241-269 Boston homeless nights in the last three years'
        score += 8
      when '270-364 Boston homeless nights in the last three years'
        score += 9
      end

      score = 1 if score.zero?
      score
    end

    def form_fields
      case title
      when pathways_title
        pathways_form_fields
      when transfer_title
        transfer_form_fields
      else
        picker_form_fields
      end
    end

    def picker_form_fields
      []
    end

    def transfer_form_fields
      {
        _transfer_assessment_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/transfer_assessment_preamble',
        },
        entry_date: {
          label: 'Date of Assessment',
          number: '',
          as: :date_picker,
        },
        _contact_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/contact_preamble',
        },
        phone_number: {
          label: 'List any working phone number(s), or the phone of a voicemail service or friend/family member we could call',
          number: '2A',
        },
        email_addresses: {
          label: 'List any working email addresses you use',
          number: '2B',
        },
        shelter_name: {
          label: 'What RRH programs do you currently stay with or work with?',
          number: '2C',
          as: :select_2,
          collection: ShelterHistory.shelter_locations,
          input_html: { data: { tags: true }},
        },
        case_manager_contact_info: {
          label: 'Do you have any case managers or agencies we could contact to get a hold of you?',
          number: '2D',
          as: :text,
        },
        mailing_address: {
          label: 'What is your mailing address?',
          number: '2E',
          as: :text,
        },
        day_locations: {
          label: 'Are there agencies, shelters or places you hang out in during the day where we could connect with you?',
          number: '2F',
          as: :select_2,
          collection: ShelterHistory.shelter_locations,
          input_html: { data: { tags: true }},
        },
        night_locations: {
          label: 'Are there agencies, shelters or places you hang out in during nights or weekends where we could connect with you?',
          number: '2G',
          as: :select_2,
          collection: ShelterHistory.shelter_locations,
          input_html: { data: { tags: true }},
        },
        other_contact: {
          label: 'Are there other ways we could contact you that we have not asked you or thought of yet?',
          number: '2H',
        },
        _household_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/household_preamble',
        },
        household_section: {
          label: 'Household Composition',
          number: '3A',
          questions: {
            household_size: {
              label: 'How many people are in the household? ',
            },
            hoh_age: {
              label: 'How old is the head of household?',
              collection: {
                '18-24' => '18-24',
                '25-49' => '25-49',
                '50+' => '50+',
              },
              as: :pretty_boolean_group,
            },
            household_details: {
              as: :partial,
              partial: 'non_hmis_assessments/pathways_version_three/household_details',
            },
            current_living_situation: {
              label: 'What is your current living situation?',
              collection: {
                _('Emergency shelter in the City of Boston') => 'Emergency shelter in the City of Boston',
                _('Outside/place not meant for human habitation within the City of Boston') => 'Outside/place not meant for human habitation within the City of Boston',
                _('Transitional housing program in the City of Boston') => 'Transitional housing program in the City of Boston',
                _('Currently fleeing violence while in your own home or doubled up with others and a Boston resident.') => 'Currently fleeing violence while in your own home or doubled up with others and a Boston resident.',
              },
              as: :pretty_boolean_group,
            },
          },
        },
        veteran_status: {
          label: 'Did you serve in the military or do you have Veteran status?',
          number: '3B',
          as: :pretty_boolean_group,
          collection: VeteranStatus.pluck(:text).map { |t| [t, t] }.to_h,
        },
        _housing_preferences_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/housing_preferences_preamble',
        },
        income_total_annual: {
          label: 'What is your total household’s estimated gross (before taxes are taken out) annual income? We ask because some of these units have income requirements. You may figure out monthly and multiply it by 12.',
          number: '4A',
        },
        youth_rrh_aggregate: {
          label: 'Youth Choice (for heads of household who are 24 yrs. or younger)  Would you like to be considered for housing programs that are',
          number: '5C',
          collection: NonHmisClient.available_youth_choices,
          as: :pretty_boolean_group,
        },
        dv_rrh_aggregate: {
          label: 'Survivor Choice (for those fleeing domestic violence): you indicated you are currently experiencing a form of violence. Would you like to be considered for housing programs that are',
          number: '5D',
          collection: NonHmisClient.available_dv_choices,
          as: :pretty_boolean_group,
        },
        _unit_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/unit_preamble',
        },
        sro_ok: {
          label: 'If you are a single adult, would you consider living in a single room occupancy (SRO)? Keep in mind smaller bedroom units may have more frequent openings',
          number: '6A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        required_number_of_bedrooms: {
          label: 'If you need a bedroom size larger than an SRO select the size below you would move into.',
          number: '6B',
          collection: {
            'Studio' => -1,
            '1' => 1,
            '2' => 2,
            '3' => 3,
            '4' => 4,
            '5' => 5,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        disability_section: {
          label: 'Are you seeking any of the following due to a disability? If yes, you may have to provide documentation of disability - related need.',
          number: '6C',
          questions: {
            requires_wheelchair_accessibility: {
              label: 'Wheelchair accessible unit',
              number: '6C',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            requires_elevator_access: {
              label: 'First floor/elevator (little to no stairs to your unit)',
              number: '6C',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            accessibility_other: {
              label: 'Other accessibility',
              number: '6C',
            },
          },
        },
        disabled_housing: {
          label: 'Are you interested in applying for housing units targeted for persons with disabilities? (You may have to provide documentation of a disability to qualify for these housing units.)',
          number: '6D',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        hiv_housing: {
          label: 'Are you interested in applying for housing units targeted for persons with an HIV+ diagnosis? (You may have to provide documentation of a HIV to qualify for these housing units.)',
          number: '6E',
          as: :pretty_boolean_group,
          collection: {
            'Yes' => 'Yes',
            'No' => 'No',
          },
          confidential: true,
        },
        affordable_housing: {
          label: 'While openings are not common, we do have different types of affordable housing. Check the types you would be willing to take if there was an opening',
          number: '6F',
          collection: {
            _('Voucher: An affordable housing “ticket” used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)') => 'Voucher',
            _('Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.') => 'Project-Based unit',
          },
          as: :pretty_checkboxes_group,
        },
        _neighborhood_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/neighborhood_preamble',
        },
        neighborhood_interests: {
          label: 'Check off all the areas you are willing to live in. Another way to decide is to figure out which places you will not live in, and check off the rest. You are not penalized if you change your mind about where you would like to live.',
          include_blank: 'Any Neighborhood / All Neighborhoods',
          number: '7A',
          collection: Neighborhood.for_select,
          as: :pretty_checkboxes_group,
        },
        _disability_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/disability_preamble',
        },
        documented_disability: {
          label: 'Disabling Condition: Have you ever been diagnosed by a licensed professional as having a disabling condition that is expected to be permanent and impede your ability to work? You do not need to disclose the condition.',
          number: '8A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Unsure' => nil,
          },
          hint: 'Note to assessor on generating an accurate response: if participant receives any type of disability benefits, you can automatically select “yes”; if you or the participant are unsure, ask them if a medical professional has ever written a letter on their behalf for disabled housing, EAEDC, or other benefits, or if they have ever tried to apply for a disability resource, even if they do not currently receive them- check yes. The assessor may also check yes if a permanent disability is observed.',
          as: :pretty_boolean_group,
        },
        background_check_issues: {
          label: 'We are asking people what factors may be in their backgrounds so we can help people prepare supporting documentation, references and other positive information to the housing authority (check all that apply)? This is NOT to screen you out for a voucher, but rather to help overcome potential admission barriers.',
          number: '8B',
          collection: {
            'A housing authority or housing program terminated your subsidy (i.e. a housing voucher, a public housing unit, etc.)' => 'A housing authority or housing program terminated your subsidy (i.e. a housing voucher, a public housing unit, etc.)',
            'You have been evicted from a legal tenancy where you were the lease holder.' => 'You have been evicted from a legal tenancy where you were the lease holder.',
            'Prior to entering shelter or sleeping outside during this episode of homelessness, you came directly from jail, prison or a pre-release program.' => 'Prior to entering shelter or sleeping outside during this episode of homelessness, you came directly from jail, prison or a pre-release program.',
            'You have been convicted (found guilty of) a violent crime' => 'You have been convicted (found guilty of) a violent crime',
            'You have been convicted (found guilty of) a drug crime' => 'You have been convicted (found guilty of) a drug crime',
            'Any member of your household is subject to a lifetime registration requirement under a state sex offender registration program.' => 'Any member of your household is subject to a lifetime registration requirement under a state sex offender registration program.',
            'Any household member has been convicted of the manufacture or production of methamphetamine in federally assisted housing.' => 'Any household member has been convicted of the manufacture or production of methamphetamine in federally assisted housing.',
            'None of the above' => 'None of the above',
          },
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
        },
        financial_assistance_end_date: {
          label: 'What date is the latest date the participant can receive financial assistance through the current rapid re-housing program (i.e. when does their financial assistance end)?',
          number: '8C',
          as: :date_picker,
        },
        days_homeless_in_the_last_three_years: {
          label: 'Warehouse Record- Length of Time Homeless: Check the participant’s record in the Warehouse; how many Boston homeless nights in the last three years does the participant have?',
          number: '9A',
        },
        additional_homeless_nights: {
          label: 'Adding Boston homeless nights: If you believe the participant has more Boston homeless nights to add to their record (unsheltered stays in Boston; and/or shelters who do not input into the Warehouse), complete the three year history and specify the number of Boston homeless nights you are adding to their length of time homeless in the warehouse. For additional days added, please have a "Documenting Current Boston Homelessness" form completed and ready to submit upon referral. You may skip this step and the form if you do not have any additional Boston homeless nights to add.',
          number: '9B',
        },
        total_days_homeless_in_the_last_three_years: {
          label: 'Total # of Boston homeless nights: Warehouse + added Boston homeless nights (input into CAS assessment)',
          hint: 'Auto calculated',
          number: '9C',
          disabled: true,
        },
        _housing_stability_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/housing_stability_preamble',
        },
        _next_step_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/next_steps_preamble',
        },
        wait_times_ack: {
          label: 'Wait Times',
          number: '',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          hint: 'Wait times can change from time to time based on how many people are interested, and the openings we have available. We encourage you to think about ways we can help you move in with friends, family, return to safe living situations, or other options since these programs may not always have openings.',
          as: :pretty_boolean_group,
        },
        not_matched_ack: {
          label: 'What should I do to try to find housing if I am not matched with housing opening?',
          number: '',
          collection: {
            'Yes' => true,
            'No' => false,

          },
          hint: 'We encourage you to keep thinking about other ways you may be able to prevent returning to homelessness, like moving in with roommates, applying for affordable housing, getting a rep payee or other ways to make housing work. ',
          as: :pretty_boolean_group,
        },
        matched_process_ack: {
          label: 'Who Will I Hear From If I Am Matched to a housing opening?',
          number: '',
          collection: {
            'Yes' => true,
            'No' => false,

          },
          hint: 'You may hear from myself or any other case managers/contacts you listed here today; you may also hear directly from the housing program, so be sure to return calls or emails even if you do not know the agency. They are going to use all of the contact information you provided us to try to connect with you as quickly as possible. If any of your contact information changes, let me know and I can change it in the assessment.',
          as: :pretty_boolean_group,
        },
        response_time_ack: {
          label: 'How Long Will I Have to Respond to a housing opening I am matched with?',
          number: '',
          collection: {
            'Yes' => true,
            'No' => false,

          },
          hint: 'In general, the housing programs will outreach to people who are matched with openings for about two weeks. They will move on to new people who may be interested after two weeks because they have to fill the openings. However, if you are interested after the two weeks, you should still return the call/email/message as you may be able to be matched to another opening at a later date.',
          as: :pretty_boolean_group,
        },
        automatic_approval_ack: {
          label: 'Am I automatically approved for the housing openings when I’m matched?',
          number: '',
          collection: {
            'Yes' => true,
            'No' => false,

          },
          hint: 'No. Today we gathered information to help figure out if you’re eligible and match you to your preferences, but the housing programs will actually verify and document eligibility at the time you are referred. All of the programs have different eligibility criteria- our system will do its best to match you with those that you should be eligible for, but there may be times where you are matched, and are not eligible, and will be offered a new opening when one comes up.',
          as: :pretty_boolean_group,
        },
      }
    end

    def pathways_form_fields
      {
        _pathways_version_three_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/pathways_version_three_preamble',
        },
        entry_date: {
          label: 'Date of Assessment',
          number: '',
          as: :date_picker,
        },
        phone_number: {
          label: 'List any working phone number(s), or the phone of a voicemail service or friend/family member we could call',
          number: '2A',
        },
        email_addresses: {
          label: 'List any working email addresses you use',
          number: '2B',
        },
        shelter_name: {
          label: 'What shelter(s) or street outreach programs do you currently stay with or work with?',
          number: '2C',
          as: :select_2,
          collection: ShelterHistory.shelter_locations,
          input_html: { data: {tags: true }},
        },
        case_manager_contact_info: {
          label: 'Do you have any case managers or agencies we could contact to get a hold of you?',
          number: '2D',
          as: :text,
        },
        mailing_address: {
          label: 'What is your mailing address?',
          number: '2E',
          as: :text,
        },
        day_locations: {
          label: 'Are there agencies, shelters or places you hang out in during the day where we could connect with you?',
          number: '2F',
        },
        night_locations: {
          label: 'Are there agencies, shelters or places you hang out in during nights or weekends where we could connect with you?',
          number: '2G',
        },
        other_contact: {
          label: 'Are there other ways we could contact you that we have not asked you or thought of yet?',
          number: '2H',
        },
        household_section: {
          label: 'Household Composition',
          number: '3A',
          questions: {
            household_size: {
              label: 'How many people are in the household? ',
            },
            hoh_age: {
              label: 'How old is the head of household?',
              collection: {
                '18-24' => '18-24',
                '25-49' => '25-49',
                '50+' => '50+',
              },
              as: :pretty_boolean_group,
            },
            current_living_situation: {
              label: 'What is your current living situation?',
              collection: {
                _('Emergency shelter in the City of Boston') => 'Emergency shelter in the City of Boston',
                _('Outside/place not meant for human habitation within the City of Boston') => 'Outside/place not meant for human habitation within the City of Boston',
                _('Transitional housing program in the City of Boston') => 'Transitional housing program in the City of Boston',
                _('Currently fleeing violence while in your own home or doubled up with others and a Boston resident.') => 'Currently fleeing violence while in your own home or doubled up with others and a Boston resident.',
              },
              as: :pretty_boolean_group,
            },
          },
        },
        veteran_status: {
          label: 'Did you serve in the military or do you have Veteran status?',
          number: '3B',
          as: :pretty_boolean_group,
          collection: VeteranStatus.pluck(:text).map { |t| [t, t] }.to_h,
        },
        pending_subsidized_housing_placement: {
          label: 'Are you about to move into a housing unit or have a voucher where you need help searching for a unit? Examples may be you have a voucher, or an offer of a public housing unit where your rent will be calculated at about 30-40% of your income?',
          number: '3D',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        housing_placement_section: {
          label: 'What type of unit are you moving into?',
          number: '3E',
          questions: {
            pending_housing_placement_type: {
              label: 'Unit type',
              collection: {
                _('I have a voucher to find a unit (Section 8, Housing Choice Voucher, CAS, MRVP, other)') => 'I have a voucher to find a unit (Section 8, Housing Choice Voucher, CAS, MRVP, other)',
                _('Public Housing unit') => 'Public Housing unit',
              },
              as: :pretty_boolean_group,
            },
            pending_housing_placement_type_other: {
              label: 'Other unit type',
            },
          },
        },
        income_total_annual: {
          label: 'What is your total household’s estimated gross (before taxes are taken out) annual income? We ask because some of these units have income requirements. You may figure out monthly and multiply it by 12.',
          number: '4A',
        },
        income_maximization_assistance_requested: {
          label: 'We have income maximization services we can offer to people who sign up for these housing opportunities and are waiting for an offer. These services include staff who are trained in resources and ways to increase your income by budgeting, applying for all benefits you may need and/or linking to employment opportunities. Are you interested in using this service while you wait for housing?',
          number: '4B',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        maximum_possible_monthly_rent: {
          label: 'What is the maximum you would or could pay for rent each month? ',
          hint: '(This is optional to pair you with potential housing opportunities; you may respond that you do not know)',
          number: '4C',
        },
        possible_housing_situation_section: {
          label: 'Would you be interested in sharing housing with roommates? Some of the benefits of sharing housing are you have more money between roommates to live in more expensive neighborhoods and you can share costs like rent and utilities so you have more money in your monthly budget.',
          number: '4D',
          questions: {
            possible_housing_situation: {
              label: 'Sharing housing',
              collection: {
                _('Yes') => 'Yes',
                _('No, I want my own home') => 'No, I want my own home',
                _('No, I have had negative roommate experiences before') => 'No, I have had negative roommate experiences before',
                _('No, I do not know anyone to share housing with') => 'No, I do not know anyone to share housing with',
              },
              as: :pretty_boolean_group,
            },
            possible_housing_situation_other: {
              label: 'Other Housing Situation',
              number: '4D',
            },
          },
        },
        rrh_desired: {
          label: 'Would you like to be considered for RRH when they have openings?',
          number: '5A',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        no_rrh_desired_section: {
          label: 'If you are not interested, what is the reason you are not interested?',
          number: '5B',
          questions: {
            no_rrh_desired_reason: {
              label: 'RRH interest',
              collection: {
                _('I have too little income and do not think I can increase it') => 'I have too little income and do not think I can increase it',
                _('I want to wait for subsidized housing') => 'I want to wait for subsidized housing',
                _('I’m undecided but may reconsider') => 'I’m undecided but may reconsider',
                _('I don’t want to live in a single room') => 'I don’t want to live in a single room',
                _('I don’t want to live in a roommate situation') => 'I don’t want to live in a roommate situation',
              },
              as: :pretty_boolean_group,
            },
            no_rrh_desired_reason_other: {
              label: 'Not interested in RRH Reason',
            },
          },
        },
        youth_rrh_aggregate: {
          label: 'Youth Choice (for heads of household who are 24 yrs. or younger)  Would you like to be considered for housing programs that are',
          number: '5C',
          collection: NonHmisClient.available_youth_choices,
          as: :pretty_boolean_group,
        },
        dv_rrh_aggregate: {
          label: 'Survivor Choice (for those fleeing domestic violence): you indicated you are currently experiencing a form of violence. Would you like to be considered for housing programs that are',
          number: '5D',
          collection: NonHmisClient.available_dv_choices,
          as: :pretty_boolean_group,
        },
        provider_agency_preference: {
          label: 'Provider Agency Preference: We cannot always match people with their preferred agency due to program capacity, we do ask if you have a preferred RRH agency to work with in case we are able to. Which agency(ies) would you prefer to work with (you may pick more than one)',
          number: '5E',
          collection: {
            _('RRH staff at 112 Southampton Street Shelter') => 'RRH staff at 112 Southampton Street Shelter',
            _('RRH staff at Woods Mullen Shelter') => 'RRH staff at Woods Mullen Shelter',
            _('RRH staff at Pine Street Inn') => 'RRH staff at Pine Street Inn',
            _('RRH staff at HomeStart') => 'RRH staff at HomeStart',
            _('RH Staff at Bridge Over Troubled Water (youth agency)') => 'RH Staff at Bridge Over Troubled Water (youth agency)',
            _('RRH Staff at Casa Myrna Vazquez (domestic violence agency)') => 'RRH Staff at Casa Myrna Vazquez (domestic violence agency)',
            _('RRH Staff at Elizabeth Stonehouse (domestic violence agency)') => 'RRH Staff at Elizabeth Stonehouse (domestic violence agency)',
            _('No preference, any agency') => 'No preference, any agency',
          },
          as: :select_2,
          input_html: { multiple: true },
        },
        rrh_th_desired: {
          label: 'Need For Shelter While Doing Housing Search (RRH): Openings are very limited and rare, but some of the rapid re-housing programs are able to offer a stable shelter option to use while you search for housing. Would you be interested in a shelter option if one were available? You may deny the shelter option if you are no longer interested at the time of rapid re-housing referral.',
          number: '5F',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        sro_ok: {
          label: 'If you are a single adult, would you consider living in a single room occupancy (SRO)? Keep in mind smaller bedroom units may have more frequent openings',
          number: '6A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        required_number_of_bedrooms: {
          label: 'If you need a bedroom size larger than an SRO select the size below you would move into.',
          number: '6B',
          collection: {
            'Studio' => -1,
            '1' => 1,
            '2' => 2,
            '3' => 3,
            '4' => 4,
            '5' => 5,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        disability_section: {
          label: 'Are you seeking any of the following due to a disability? If yes, you may have to provide documentation of disability - related need.',
          number: '6C',
          questions: {
            requires_wheelchair_accessibility: {
              label: 'Wheelchair accessible unit',
              number: '6C',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            requires_elevator_access: {
              label: 'First floor/elevator (little to no stairs to your unit)',
              number: '6C',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            accessibility_other: {
              label: 'Other accessibility',
              number: '6C',
            },
          },
        },
        disabled_housing: {
          label: 'Are you interested in applying for housing units targeted for persons with disabilities? (You may have to provide documentation of a disability to qualify for these housing units.)',
          number: '6D',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        hiv_housing: {
          label: 'Are you interested in applying for housing units targeted for persons with an HIV+ diagnosis? (You may have to provide documentation of a HIV to qualify for these housing units.)',
          number: '6E',
          as: :pretty_boolean_group,
          collection: {
            'Yes' => 'Yes',
            'No' => 'No',
          },
          confidential: true,
        },
        affordable_housing: {
          label: 'While openings are not common, we do have different types of affordable housing. Check the types you would be willing to take if there was an opening',
          number: '6F',
          collection: {
            _('Voucher: An affordable housing “ticket” used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)') => 'Voucher',
            _('Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.') => 'Project-Based unit',
          },
          as: :pretty_checkboxes_group,
        },
        interested_in_set_asides: {
          label: 'Client would like to be added to the homeless set aside interest list',
          number: '6I.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          hint: 'Client is aware that signing up is not an actual application to a housing development, that they will only be notified of openings in neighborhoods they have selected when they near the top of the interest list, and that being eligible and even referred to a homeless set aside unit does not guarantee an offer of housing.',
        },
        neighborhood_interests: {
          label: 'Check off all the areas you are willing to live in. Another way to decide is to figure out which places you will not live in, and check off the rest. You are not penalized if you change your mind about where you would like to live.',
          include_blank: 'Any Neighborhood / All Neighborhoods',
          number: '7A',
          collection: Neighborhood.for_select,
          as: :pretty_checkboxes_group,
        },
        documented_disability: {
          label: 'Disabling Condition: Have you ever been diagnosed by a licensed professional as having a disabling condition that is expected to be permanent and impede your ability to work? You do not need to disclose the condition.',
          number: '8A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Unsure' => nil,
          },
          as: :pretty_boolean_group,
        },
        health_prioritized: {
          label: 'COVID High Risk: We are collecting information on who may be high risk of severe illness due to COVID in case there are future outbreaks. Do you have any of the following conditions?<br />
          65+ years old<br />
          Cancer<br />
          Chronic kidney disease<br />
          COPD (chronic obstructive pulmonary disease)<br />
          Weakened immune system due to an organ transplant<br />
          Body mass index of 30 or higher<br />
          Serious heart condition (heart failure, coronary artery disease, cardiomyopathies)<br />
          Sickle cell disease<br />
          Type 2 diabetes
          '.html_safe,
          number: '8B',
          collection: {
            'Yes' => true,
            'No' => false,
          },
          as: :pretty_boolean_group,
        },
        service_need_indicators: {
          label: 'Service Need Indicators: Now we’ll ask you if you have experienced any conditions so we can figure out if we have housing options with services to meet these needs. Check all that apply',
          number: '8C',
          collection: {
            'Short term memory loss' => 'Short term memory loss',
            'A medical provider has said you have experienced a traumatic head or brain injury' => 'A medical provider has said you have experienced a traumatic head or brain injury',
            'Had a housing voucher but it was terminated due to search taking too long' => 'Had a housing voucher but it was terminated due to search taking too long',
            'Terminated from having a voucher, or a public housing or other affordable unit' => 'Terminated from having a voucher, or a public housing or other affordable unit',
            'Had/have a court appointed guardian' => 'Had/have a court appointed guardian',
            'Have difficulty completing tasks like dressing, eating, showering, taking medications etc.' => 'Have difficulty completing tasks like dressing, eating, showering, taking medications etc.',
            'Currently have a representative payee assigned to me' => 'Currently have a representative payee assigned to me',
            'Current client of Dept. of Mental Health or Dept. of Developmental Services' => 'Current client of Dept. of Mental Health or Dept. of Developmental Services',
          },
          as: :select_2,
          input_html: { multiple: true },
        },
        medical_care_last_six_months: {
          label: 'In the past 6 months, about how many times have you used emergency or inpatient medical or psychiatric care? This would include emergency room visits, staying overnight in a hospital or detox facility. (For the assessor): If you have knowledge of a participant’s admissions from medical records or care you provide, you may fill in this number.',
          number: '8D',
          collection: {
            '1' => 1,
            '2' => 2,
            '3' => 3,
            '4' => 4,
            '5' => 5,
            '6' => 6,
            '7' => 7,
            '8' => 8,
            '9' => 9,
            '10+' => 10,
          },
          as: :select_2,
        },
        intensive_needs_section: {
          label: '(For the assessor): If you observe another indicator that the participant needs very intensive, frequent, in-home supportive services once they are housed, complete the field below. This field should only be used sparingly to identify people with the highest needs. Examples may include: frequent bars/terminations from shelters; severe cold weather injuries (hypothermia, amputation, etc.); history of hoarding; recent overdose; severe medical fragility; etc.',
          number: '8E',
          questions: {
            intensive_needs: {
              label: 'Intensive Needs',
              collection: {
                '2+ shelter bars or terminations in the last year' => '2+ shelter bars or terminations in the last year',
                'Experienced cold weather injuries (hypothermia, amputations, etc) in the last year' => 'Experienced cold weather injuries (hypothermia, amputations, etc) in the last year',
                'History of hoarding' => 'History of hoarding',
                'Drug overdose in the last year' => 'Drug overdose in the last year',
                'Severe medical fragility' => 'Severe medical fragility',
              },
              as: :pretty_checkboxes_group,
            },
            intensive_needs_other: {
              label: 'Other intensive needs',
            },
          },
        },
        background_check_issues: {
          label: 'Some housing programs do background checks to decide admissions into their units. We are asking people what factors may be in their backgrounds so we can shape our services to overcome these barriers. Have you experienced any of the following (check all that apply)?',
          number: '8F',
          collection: {
            'Evicted by a landlord - non-payment of rent' => 'Evicted by a landlord - non-payment of rent',
            'Evicted by a landlord - lease violations' => 'Evicted by a landlord - lease violations',
            'Owe a housing program past rent' => 'Owe a housing program past rent',
            'Convicted of a violent crime' => 'Convicted of a violent crime',
            'Registered Sex Offender' => 'Registered Sex Offender',
          },
          as: :select_2,
          input_html: { multiple: true },
        },
        days_homeless_in_the_last_three_years: {
          label: 'Warehouse Record- Length of Time Homeless: Check the participant’s record in the Warehouse; how many Boston homeless nights in the last three years does the participant have?',
          number: '9A',
        },
        additional_homeless_nights: {
          label: 'Adding Boston homeless nights: If you believe the participant has more Boston homeless nights to add to their record (unsheltered stays in Boston; and/or shelters who do not input into the Warehouse), complete the three year history and specify the number of Boston homeless nights you are adding to their length of time homeless in the warehouse. For additional days added, please have a "Documenting Current Boston Homelessness" form completed and ready to submit upon referral. You may skip this step and the form if you do not have any additional Boston homeless nights to add.',
          number: '9B',
        },
        total_days_homeless_in_the_last_three_years: {
          label: 'Total # of Boston homeless nights: Warehouse + added Boston homeless nights (input into CAS assessment)',
          hint: 'Auto calculated',
          number: '9C',
          disabled: true,
        },
        homeless_night_range: {
          label: 'Select the range the participant’s Boston homeless nights fall into',
          number: '9D',
          collection: {
            'Fleeing Domestic Violence (no range needed)' => 'Fleeing Domestic Violence (no range needed)',
            '0-60 Boston homeless nights in the last three years' => '0-60 Boston homeless nights in the last three years',
            '61-90 Boston homeless nights in the last three years' => '61-90 Boston homeless nights in the last three years',
            '91-120 Boston homeless nights in the last three years' => '91-120 Boston homeless nights in the last three years',
            '121-150 Boston homeless nights in the last three years' => '121-150 Boston homeless nights in the last three years',
            '151-180 Boston homeless nights in the last three years' => '151-180 Boston homeless nights in the last three years',
            '181-210 Boston homeless nights in the last three years' => '181-210 Boston homeless nights in the last three years',
            '211-240 Boston homeless nights in the last three years' => '211-240 Boston homeless nights in the last three years',
            '241-269 Boston homeless nights in the last three years' => '241-269 Boston homeless nights in the last three years',
            '270-364 Boston homeless nights in the last three years' => '270-364 Boston homeless nights in the last three years',
            '365+ Boston homeless nights in the last three years' => '365+ Boston homeless nights in the last three years',
          },
          as: :pretty_boolean_group,
        },
        notes: {
          label: 'Optional notes for assessor to communicate any specific information to housing programs.',
          number: '10A',
        },
      }
    end
  end
end
