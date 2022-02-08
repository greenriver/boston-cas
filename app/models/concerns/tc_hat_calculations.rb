###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module TcHatCalculations
  extend ActiveSupport::Concern

  included do
    def hud_assessment_level
      assessment_level
    end

    def calculated_score
      total_days_homeless_in_the_last_three_years
    end

    def form_fields
      {
        entry_date: {
          label: 'Date of Assessment',
          as: :date_picker,
          required: true,
        },
        hud_assessment_location: {
          label: 'Assessment Location',
          as: :select_2,
          collection: hud_assessment_locations,
          required: true,
        },
        hud_assessment_type: {
          label: 'Assessment Type',
          as: :select_2,
          collection: hud_assessment_types,
          required: true,
        },
        tc_hat_assessment_level: {
          label: 'Assessment Level',
          collection: {
            'Crisis Needs Assessment' => 1,
            'Housing Needs Assessment' => 2,
          },
          as: :pretty_boolean_group,
        },
        days_homeless_in_the_last_three_years: {
          label: 'Total Days Homeless in the Past Three Years',
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
        },
        need_daily_assistance: {
          label: '[STAFF RESPONSE] Only check this box if you feel the client is unable to live alone due to needing around the clock care or that they may be dangerous/harmful to themselves or their neighbors without ongoing support. (If unknown, you may skip this question.)',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
        },
        _needs_daily_assistance_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/tc_hat/needs_daily_assistance_preamble',
        },
        ongoing_support_reason: {
          label: '[STAFF RESPONSE] Explain why this client cannot live independently',
          question_wrapper: { class: 'jDailyAssistance' },
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
        },
        strengths: {
          label: 'Strengths (Check all that apply.)',
          collection: Rules::Strength.new.available_strengths.to_h.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
        },
        challenges: {
          label: 'Possible challenges for housing placement options (Check all that apply)',
          collection: Rules::Challenge.new.available_challenges.to_h.invert,
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
        },

        setting: {
          label: 'Current living situation - select one (required)?',
          collection: {
            _('Emergency Shelter (includes domestic violence shelters)') => 'Emergency Shelter',
            _('Unsheltered (outside, in a place not meant for human habitation, etc.)') => 'Unsheltered',
            _('Transitional Housing') => 'Transitional Housing',
            _('Actively fleeing domestic violence in your home or staying with someone else') => 'Actively fleeing DV',
          },
          as: :pretty_boolean_group,
          required: true,
        },
        phone_number: {
          label: 'Client phone number',
        },
        email_addresses: {
          label: 'List any working email addresses you use',
        },
        shelter_name: {
          label: 'What shelter(s) or street outreach programs do you currently stay with or work with?',
          as: :select_2,
          collection: ShelterHistory.shelter_locations,
          input_html: { data: { tags: true } },
        },
        case_manager_contact_info: {
          label: 'Do you have any case managers or agencies we could contact to get a hold of you?',
          as: :text,
          hint: 'Please provide email address and full name for each contact listed',
        },
        mailing_address: {
          label: 'Client\'s Mailing Address',
          as: :text,
        },
        day_locations: {
          label: 'Are there agencies, shelters or places you hang out in during the day where we could connect with you?',
        },
        night_locations: {
          label: 'Are there agencies, shelters or places you hang out in during nights or weekends where we could connect with you?',
        },
        other_contact: {
          label: 'Are there other ways we could contact you that we have not asked you or thought of yet?',
        },
        household_section: {
          label: 'Household Composition',
          questions: {
            household_size: {
              label: 'How many people are in the household? ',
              input_html: { class: 'jHouseholdTrigger' },
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
          },
        },
        veteran_status: {
          label: 'Did you serve in the military or do you have Veteran status?',

          as: :pretty_boolean_group,
          collection: VeteranStatus.pluck(:text).map { |t| [t, t] }.to_h,
        },
        income_total_annual: {
          label: 'What is your total household’s estimated gross (before taxes are taken out) annual income? We ask because some of these units have income requirements. You may figure out monthly and multiply it by 12.',

        },
        youth_rrh_aggregate: {
          label: 'Youth Choice (for heads of household who are 24 yrs. or younger)  Would you like to be considered for housing programs that are',

          collection: NonHmisClient.available_youth_choices,
          as: :pretty_boolean_group,
        },
        dv_rrh_aggregate: {
          label: 'Survivor Choice (for those fleeing domestic violence): you indicated you are currently experiencing a form of violence. Would you like to be considered for housing programs that are',

          collection: NonHmisClient.available_dv_choices,
          as: :pretty_boolean_group,
        },
        sro_ok: {
          label: 'If you are a single adult, would you consider living in a single room occupancy (SRO)?',
          number: '6A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        required_number_of_bedrooms: {
          label: 'If you need a bedroom size larger than an SRO, studio or 1 bedroom, select the size below you would move into.',
          number: '6B',
          collection: {
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
            _('Voucher: An affordable housing "ticket" used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)') => 'Voucher',
            _('Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.') => 'Project-Based unit',
          },
          as: :pretty_checkboxes_group,
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
            'Unknown' => nil,
          },
          hint: 'Note to assessor on generating an accurate response: if participant receives any type of disability benefits, you can automatically select "yes"; if you or the participant are unsure, ask them if a medical professional has ever written a letter on their behalf for disabled housing, EAEDC, or other benefits, or if they have ever tried to apply for a disability resource, even if they do not currently receive them- check yes. The assessor may also check yes if a permanent disability is observed.',
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
          label: 'Latest Date Eligible for Financial Assistance',
          number: '8C',
          as: :date_picker,
        },
      }
    end
  end
end
