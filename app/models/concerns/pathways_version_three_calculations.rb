###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module PathwaysVersionThreeCalculations
  extend ActiveSupport::Concern

  included do
    validates_presence_of :wait_times_ack, :not_matched_ack, :matched_process_ack, :response_time_ack, :automatic_approval_ack, :entry_date, :hud_assessment_location, :hud_assessment_type, :setting, on: [:create, :update]

    def title
      return pathways_title if assessment_type.blank?

      assessment_type_options[assessment_type.to_sym][:title]
    end

    def for_matching
      options = case assessment_type.to_sym
      when :pathways_2021
        {
          'PathwaysVersionThreePathways' => pathways_title,
        }
      when :transfer_assessment
        {
          'PathwaysVersionThreeTransfer' => transfer_title,
        }
      end
      status = if identified? then 'Identified' else 'Deidentified' end
      options.map do |k, v|
        [
          "#{status}#{k}",
          "#{v} - #{status}",
        ]
      end.to_h
    end

    def hud_assessment_level
      case assessment_type.to_sym
      when :pathways_2021
        2 # Housing Needs Assessment
      when :transfer_assessment
        1 # Crisis Needs Assessment
      end
    end

    def tie_breaker_date
      case assessment_type.to_sym
      when :pathways_2021
        entry_date
      when :transfer_assessment
        financial_assistance_end_date
      end
    end

    def self.export_fields(assessment_name)
      shared = super.merge(
        {
          rrh_assessment_collected_at: {
            title: 'Assessment Date',
            client_field: :rrh_assessment_collected_at,
          },
          setting: {
            title: Translation.translate('Current Living Situation'),
            client_field: :majority_sheltered_for_export,
          },
          veteran_status: {
            title: 'Veteran',
            client_field: :veteran_status_for_export,
          },
          youth_rrh_aggregate: {
            title: 'Interested in Youth Rapid Re-Housing',
            client_field: :youth_rrh_desired_for_export,
          },
          dv_rrh_aggregate: {
            title: 'Interested in DV Rapid Re-Housing',
            client_field: :dv_rrh_desired_for_export,
          },
          sro_ok: {
            title: 'Would you consider living in a single room occupancy (SRO)?',
            client_field: :sro_ok_for_export,
          },
          required_number_of_bedrooms: {
            title: 'Minimum number of bedrooms required?',
            client_field: :required_number_of_bedrooms,
          },
          requires_wheelchair_accessibility: {
            title: 'Requires wheelchair accessibility?',
            client_field: :requires_wheelchair_accessibility_for_export,
          },
          requires_elevator_access: {
            title: 'Requires elevator access or ground floor unit?',
            client_field: :requires_elevator_access_for_export,
          },
          neighborhood_interests: {
            title: 'Neighborhood Interests',
            client_field: :neighborhood_interests_for_export,
          },
          financial_assistance_end_date: {
            title: Translation.translate('Latest Date Eligible for Financial Assistance'),
            client_field: :financial_assistance_end_date,
          },
          total_days_homeless_in_the_last_three_years: {
            title: 'Days Homeless in Last Three Years',
            client_field: :days_homeless_in_last_three_years,
          },
          need_daily_assistance: {
            title: Translation.translate('Needs a higher level of care'),
            client_field: :need_daily_assistance_for_export,
          },
          # The following may be needed eventually, but aren't currently included
          # disabled_housing: {
          #   title: 'Interested in disabled housing',
          #   client_field: :interested_in_disabled_housing,
          # },
          # affordable_housing: {
          #   title: 'Interested in affordable housing',
          #   client_field: :affordable_housing,
          # },
        },
      )
      case assessment_name
      when 'Pathways 2021'
        shared.merge(
          {
            income_maximization_assistance_requested: {
              title: 'Interested in income maximization services',
              client_field: :income_maximization_assistance_requested,
            },
          },
        )
      when 'Transfer Assessment'
        shared
      end
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
      'Transfer Assessment 2021'
    end

    def pathways_description
      Translation.translate('We want to reach you when there is a housing program opening for you.')
    end

    def transfer_description
      Translation.translate('Gather information about a rapid re-housing (RRH) participant’s housing stability.')
    end

    def assessment_type_options
      {
        pathways_assessment_type => { title: pathways_title, description: pathways_description },
        transfer_assessment_type => { title: transfer_title, description: transfer_description },
      }
    end

    def locked?
      return false if lockable_fields.empty?
      return false if locked_until.blank?
      return false if Date.current >= locked_until

      ! in_lock_grace_period?
    end

    def lockable_fields
      return [] unless assessment_type == pathways_assessment_type.to_s

      [
        :days_homeless_in_the_last_three_years,
        :additional_homeless_nights,
        :additional_homeless_nights_sheltered,
        :homeless_nights_sheltered,
        :additional_homeless_nights_unsheltered,
        :homeless_nights_unsheltered,
        :total_days_homeless_in_the_last_three_years,
      ]
    end

    def lock
      return if locked?
      return if lockable_fields.empty?

      lock_days = Config.get(:lock_days)
      return if lock_days.zero?
      return if in_lock_grace_period?

      self.locked_until = Date.current + lock_days.days
    end

    def in_lock_grace_period?
      return true if lockable_fields.empty?
      return false if locked_until.blank?

      lock_days = Config.get(:lock_days)
      lock_grace_days = Config.get(:lock_grace_days)

      locked_window = lock_days - lock_grace_days
      return true unless locked_window.positive?

      Date.current < (locked_until - locked_window.days)
    end

    def requires_assessment_type_choice?
      true
    end

    def score_for(field)
      value = send(field)
      options = send("#{field}_options")
      options[value].try(:[], :score) || 0
    end

    def collection_for(field)
      options = send("#{field}_options")
      options.map do |k, opt|
        [k, opt[:label]]
      end.to_h.invert
    end

    private def times_moved_options
      {
        'never' => {
          label: 'Client has not moved while enrolled',
          score: 0,
        },
        'once' => {
          label: 'Once',
          score: 2,
        },
        'two or more' => {
          label: 'Two or more times',
          score: 4,
        },
      }
    end

    private def health_severity_options
      {
        'no health concerns' => {
          label: 'Client has no serious health concerns',
          score: 0,
        },
        'mild symptoms' => {
          label: 'Mild symptoms that are only slight impairments to daily functioning, or 1-2 ER visits in the past six months',
          score: 1,
        },
        'moderate symptoms' => {
          label: 'Moderate symptoms that impact some day-to-day functioning, or 3-5 ER visits in the past six months, or 1 hospitalization in the past 6 months',
          score: 2,
        },
        'severe symptoms' => {
          label: 'Severe symptoms that impact nearly all day-to-day functioning, or 6-8 ER visits in the past six months, or 2-3 hospitalizations in the past 6 months',
          score: 4,
        },
        'in crisis' => {
          label: 'Client is in crisis – life is at imminent risk; and/or medical prognosis is less than 1 year, or 9+ ER visits in the past 6 months, or 4+ hospitalizations in the past 6 months',
          score: 6,
        },
      }
    end

    private def ever_experienced_dv_options
      {
        'never' => {
          label: 'Client has never experienced domestic violence or an on-site assault',
          score: 0,
        },
        'history of dv' => {
          label: 'History of DV or on-site assaults, though environment is currently safe',
          score: 1,
        },
        'moderately safe' => {
          label: 'Safety is moderately adequate',
          score: 2,
        },
        'minimally safe' => {
          label: 'Current level of safety is minimally adequate – ongoing safety planning is needed',
          score: 3,
        },
        'in crisis' => {
          label: 'In-crisis – life at serious imminent risk due to DV or on-site assaults',
          score: 6,
        },
      }
    end

    private def eviction_risk_options
      {
        'not at risk' => {
          label: 'Client is not currently at risk of eviction from their current unit',
          score: 0,
        },
        'verbal threat' => {
          label: 'Property owner has verbally threatened eviction to either the tenant or the case manager but not taken any formal steps',
          score: 1,
        },
        'notice-to-quit' => {
          label: 'Client has received a notice-to-quit terminating their tenancy',
          score: 2,
        },
        'court summons' => {
          label: 'Client has received a court summons & complaint and is facing eviction for non-payment of rent',
          score: 4,
        },
        'eviction for cause' => {
          label: 'Client has received a court summons & complaint and is facing eviction for cause (e.g. lease violations, criminal activity, etc.)',
          score: 6,
        },
      }
    end

    private def need_daily_assistance_options
      {
        'no assistance' => {
          label: 'Client requires little to no assistance with tasks of daily living',
          score: 0,
        },
        'minimal assistance' => {
          label: 'Client requires minimal assistance with some tasks of daily living',
          score: 1,
        },
        'requires assistance minor' => {
          label: 'Client requires assistance with minor tasks of daily living (eg, brushing teeth, etc)',
          score: 3,
        },
        'requires assistance all' => {
          label: 'Client requires assistance with nearly all major tasks of daily living (eg, eating, bathing, etc)',
          score: 6,
        },
      }
    end

    private def any_income_options
      {
        'consistent income' => {
          label: 'Client has a consistent and adequate source of income',
          score: 0,
        },
        'unstable income' => {
          label: 'Client has an unstable and/or inadequate source of income',
          score: 1,
        },
        'no income' => {
          label: 'Client has no income',
          score: 2,
        },
      }
    end

    private def income_source_options
      {
        'documented income' => {
          label: 'Client\'s income is fully documented and reportable',
          score: 0,
        },
        'undocumented income' => {
          label: 'Case manager has observed that client may be relying on unreportable income (i.e. under the table work, sex work, etc.) for daily living expenses',
          score: 2,
        },
      }
    end

    private def positive_relationship_options
      {
        'consistent support' => {
          label: 'Client has consistent and adequate support systems in the form of friends and/or family',
          score: 0,
        },
        'some support' => {
          label: 'Client has some support systems in the form of friends and/or family, though it is not always stable or sufficient',
          score: 1,
        },
        'no support' => {
          label: 'Client has no support systems and is entirely dependent on staff for support',
          score: 2,
        },
      }
    end

    private def legal_concerns_options
      {
        'no concerns' => {
          label: 'Client has no legal concerns',
          score: 0,
        },
        'insignificant concerns' => {
          label: 'Legal concerns will not significantly impair access to housing',
          score: 1,
        },
        'major concerns' => {
          label: 'Client has major legal concerns that significantly impair access to housing',
          score: 2,
        },
      }
    end

    private def healthcare_coverage_options
      {
        'stable' => {
          label: 'Client has stable, sufficient healthcare coverage',
          score: 0,
        },
        'unstable' => {
          label: 'Client has unstable or insufficient healthcare coverage',
          score: 1,
        },
      }
    end

    private def childcare_options
      {
        'no concerns' => {
          label: 'Client has no childcare concerns',
          score: 0,
        },
        'unstable' => {
          label: 'Client has unstable or insufficient access to childcare',
          score: 1,
        },
      }
    end

    def calculated_score
      return total_days_homeless_in_the_last_three_years if assessment_type == pathways_assessment_type.to_s

      score = 0
      score += score_for(:times_moved)
      score += score_for(:health_severity)
      score += score_for(:ever_experienced_dv)
      score += score_for(:eviction_risk)
      score += score_for(:need_daily_assistance)
      score += score_for(:any_income)
      score += score_for(:income_source)
      score += score_for(:positive_relationship)
      score += score_for(:legal_concerns)
      score += score_for(:healthcare_coverage)
      score += score_for(:childcare)

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
          required: true,
        },
        hud_assessment_location: {
          label: 'Assessment Location',
          number: '',
          as: :select_2,
          collection: hud_assessment_locations,
          required: true,
        },
        hud_assessment_type: {
          label: 'Assessment Type',
          number: '',
          as: :select_2,
          collection: hud_assessment_types,
          required: true,
        },
        setting: {
          label: 'Current living situation - select one (required)?',
          number: '',
          collection: {
            Translation.translate('Emergency Shelter (includes domestic violence shelters)') => 'Emergency Shelter',
            Translation.translate('Unsheltered (outside, in a place not meant for human habitation, etc.)') => 'Unsheltered',
            Translation.translate('Transitional Housing') => 'Transitional Housing',
            Translation.translate('Actively fleeing domestic violence in your home or staying with someone else') => 'Actively fleeing DV',
          },
          as: :pretty_boolean_group,
          required: true,
        },
        _contact_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/contact_preamble',
        },
        phone_number: {
          label: 'Client phone number',
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
          input_html: { data: { tags: true } },
        },
        case_manager_contact_info: {
          label: 'Do you have any case managers or agencies we could contact to get a hold of you?',
          number: '2D',
          as: :text,
          hint: 'Please provide email address and full name for each contact listed',
        },
        mailing_address: {
          label: 'Client\'s Mailing Address',
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
            household_details: {
              as: :partial,
              partial: 'non_hmis_assessments/pathways_version_three/household_details',
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
            Translation.translate('Voucher: An affordable housing "ticket" used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)') => 'Voucher',
            Translation.translate('Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.') => 'Project-Based unit',
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
        _household_history_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/transfer_household_history_preamble',
        },
        homeless_nights_sheltered: {
          label: 'How many sheltered Boston homeless nights does the participant\'s Window into the Warehouse record show?',
          number: '9A',
        },
        homeless_nights_unsheltered: {
          label: 'How many unsheltered Boston homeless nights does the participant\'s Window into the Warehouse record show?',
          number: '9B',
        },
        _additional_homeless_nights_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/additional_homeless_nights_preamble',
        },
        additional_homeless_nights_sheltered: {
          label: 'Sheltered Boston homeless nights you are adding to their length of time homeless in the warehouse.',
          number: '9C',
        },
        additional_homeless_nights_unsheltered: {
          label: 'Unsheltered Boston homeless nights you are adding to their length of time homeless in the warehouse.',
          number: '9D',
        },
        total_days_homeless_in_the_last_three_years: {
          label: 'Total # of Boston Homeless Nights: (9a+9b+9c+9d)',
          hint: 'Auto calculated',
          number: '9E',
          disabled: true,
        },
        _housing_stability_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/housing_stability_preamble',
        },
        times_moved: {
          label: 'How many times have you moved while enrolled in rapid re-housing?',
          number: '',
          as: :select_2,
          collection: collection_for(:times_moved),
        },
        health_severity: {
          label: 'How serious are your health concerns right now (physical, mental health, substance use)?',
          hint: 'Or how often have you been in the emergency room (ER) in the last 6 months?',
          number: '',
          as: :select_2,
          collection: collection_for(:health_severity),
        },
        ever_experienced_dv: {
          label: 'Have you or are you currently experiencing domestic violence?',
          number: '',
          as: :select_2,
          collection: collection_for(:ever_experienced_dv),
        },
        eviction_risk: {
          label: 'Are you currently at risk of being evicted by your landlord?',
          number: '',
          as: :select_2,
          collection: collection_for(:eviction_risk),
        },
        need_daily_assistance: {
          label: 'Do you ever need assistance with daily activities like eating, bathing/showering, dressing?',
          number: '',
          as: :select_2,
          collection: collection_for(:need_daily_assistance),
        },
        any_income: {
          label: 'Do you have any income right now?',
          number: '',
          as: :select_2,
          collection: collection_for(:any_income),
        },
        income_source: {
          label: 'What is the source of the income?',
          number: '',
          as: :select_2,
          collection: collection_for(:income_source),
        },
        positive_relationship: {
          label: 'Do you currently have positive family or friend relationships in your support network?',
          number: '',
          as: :select_2,
          collection: collection_for(:positive_relationship),
        },
        legal_concerns: {
          label: 'Do you have any active legal concerns, open court cases, or convictions that may come up when we apply for other housing?',
          number: '',
          as: :select_2,
          collection: collection_for(:legal_concerns),
        },
        healthcare_coverage: {
          label: 'Do you currently have healthcare coverage?',
          number: '',
          as: :select_2,
          collection: collection_for(:healthcare_coverage),
        },
        childcare: {
          label: 'Do you currently have childcare?',
          number: '',
          as: :select_2,
          collection: collection_for(:childcare),
        },
        _next_step_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/next_steps_preamble',
        },
        wait_times_ack: {
          label: 'Wait Times',
          number: '',
          hint: 'Wait times can change from time to time based on how many people are interested, and the openings we have available.  We also have a few priority populations we have to serve first if there are limited openings - these are young people, those who have been homeless the longest and people in an unsafe situation.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        not_matched_ack: {
          label: 'What should I do to try to find housing if I am not matched with housing opening?',
          number: '',
          hint: 'We encourage you to think about ways we can help you move in with friends, family, return to safe living situations, or other options since these programs may not always have openings.  We encourage you to keep thinking about other ways you may be able to move out of homelessness, like with roommates or people you know at the same time you are applying for affordable housing. If you think of an option, you can always be reassessed to see if we can help with the move in.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        matched_process_ack: {
          label: 'Who Will I Hear From If I Am Matched to a housing opening?',
          number: '',
          hint: 'You may hear from me or any other case managers/contacts you listed here today; you may also hear directly from the housing program, so be sure to return calls or emails even if you do not know the agency. They are going to use all of the contact information you provided us to try to connect with you as quickly as possible. If any of your contact information changes, let me know and I can change it in the assessment.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        response_time_ack: {
          label: 'How Long Will I Have to Respond to a housing opening I am matched with?',
          number: '',
          hint: 'In general, the housing programs will outreach to people who are matched with openings for about two weeks. They will move on to new people who may be interested after two weeks because they have to fill the openings. However, if you are interested after the two weeks, you should still return the call/email/message as you may be able to be matched to another opening at a later date.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        automatic_approval_ack: {
          label: 'Am I automatically approved for the housing openings when I’m matched?',
          number: '',
          hint: 'No. Today we gathered information to help figure out if you’re eligible and match you to your preferences, but the housing programs will actually verify and document eligibility at the time you are referred. All of the programs have different eligibility criteria- our system will do its best to match you with those that you should be eligible for, but there may be times where you are matched, and are not eligible, and will be offered a new opening when one comes up.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
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
          required: true,
        },
        hud_assessment_location: {
          label: 'Assessment Location',
          number: '',
          as: :select_2,
          collection: hud_assessment_locations,
          required: true,
        },
        hud_assessment_type: {
          label: 'Assessment Type',
          number: '',
          as: :select_2,
          collection: hud_assessment_types,
          required: true,
        },
        setting: {
          label: 'Current living situation - select one (required)?',
          number: '',
          collection: {
            Translation.translate('Emergency Shelter (includes domestic violence shelters)') => 'Emergency Shelter',
            Translation.translate('Unsheltered (outside, in a place not meant for human habitation, etc.)') => 'Unsheltered',
            Translation.translate('Transitional Housing') => 'Transitional Housing',
            Translation.translate('Actively fleeing domestic violence in your home or staying with someone else') => 'Actively fleeing DV',
          },
          as: :pretty_boolean_group,
        },
        _contact_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/contact_preamble',
        },
        phone_number: {
          label: 'Client phone number',
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
          input_html: { data: { tags: true } },
        },
        case_manager_contact_info: {
          label: 'Do you have any case managers or agencies we could contact to get ahold of you?',
          number: '2D',
          as: :text,
          hint: 'Please provide email address and full name for each contact listed',
        },
        day_locations: {
          label: 'Are there agencies, shelters or places you hang out in during the day where we could connect with you?',
          number: '2E',
        },
        night_locations: {
          label: 'Are there agencies, shelters or places you hang out in during nights or weekends where we could connect with you?',
          number: '2F',
        },
        other_contact: {
          label: 'Are there other ways we could contact you that we have not asked you or thought of yet?',
          number: '2G',
        },
        _household_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/pathways_household_preamble',
        },
        household_section: {
          label: 'Household Composition',
          number: '3A',
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
            household_details: {
              as: :partial,
              partial: 'non_hmis_assessments/pathways_version_three/household_details',
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
        income_maximization_assistance_requested: {
          label: 'We have income maximization services we can offer to people who sign up for these housing opportunities and are waiting for an offer. These services include staff who are trained in resources and ways to increase your income by budgeting, applying for all benefits you may need and/or linking to employment opportunities. Are you interested in using this service while you wait for housing?',
          number: '4B',
          # hint: Translation.translate('Note for Assessor Staff regarding income maximization'),
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
                Translation.translate('Yes') => 'Yes',
                Translation.translate('No, I want my own home') => 'No, I want my own home',
                Translation.translate('No, I have had negative roommate experiences before') => 'No, I have had negative roommate experiences before',
                Translation.translate('No, I do not know anyone to share housing with') => 'No, I do not know anyone to share housing with',
              },
              as: :pretty_boolean_group,
            },
            # possible_housing_situation_other: {
            #   label: 'Other Housing Situation',
            #   number: '4D',
            # },
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
        _unit_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/unit_preamble',
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
          label: '​​If you need a bedroom size larger than an SRO, studio or 1 bedroom, select the size below',
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
            Translation.translate('Voucher: An affordable housing "ticket" used to find a home with private landlords. It is mobile, so you can move units and still keep the affordability (about 30-40% of your income for rent)') => 'Voucher',
            Translation.translate('Project-Based unit: The unit is affordable (about 30-40% of your income), but the affordability is attached to the unit. It is not mobile- if you leave, you will lose the affordability. You do not have to do a full housing search in the private market with landlords because the actual unit would be open and available.') => 'Project-Based unit',
          },
          as: :pretty_checkboxes_group,
        },
        # interested_in_set_asides: {
        #   label: 'Client would like to be added to the homeless set aside interest list',
        #   number: '6I.',
        #   as: :pretty_boolean,
        #   wrapper: :custom_boolean,
        #   hint: 'Client is aware that signing up is not an actual application to a housing development, that they will only be notified of openings in neighborhoods they have selected when they near the top of the interest list, and that being eligible and even referred to a homeless set aside unit does not guarantee an offer of housing.',
        # },
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
          hint: 'Note to assessor on generating an accurate response: if participant receives any type of disability benefits, you can automatically select "yes"; if you or the participant are unsure, ask them if a medical professional has ever written a letter on their behalf for disabled housing, EAEDC, or other benefits, or if they have ever tried to apply for a disability resource, even if they do not currently receive them- check yes. The assessor may also check yes if a permanent disability is observed.',
          number: '8A',
          collection: {
            'Yes' => true,
            'No' => false,
            'Unknown' => nil,
          },
          as: :pretty_boolean_group,
        },
        denial_required: {
          label: 'There are two circumstances where the housing authorities administering these vouchers are required to deny an applicant. In an effort to be considerate of your time, it is best for us to figure out whether these barriers might come up for you now. Have you experienced any of the following? (Check all that apply)',
          number: '8B',
          collection: {
            Translation.translate('Any household member has been convicted of the manufacture or production of methamphetamine in federally assisted housing') => 'manufacture or production of methamphetamine in household',
            Translation.translate('Any member of your household is subject to a lifetime registration requirement under a state sex offender registration program.') => 'lifetime sex offender in household',
            Translation.translate('None of the above ') => 'none',
          },
          as: :pretty_checkboxes_group,
        },
        background_check_issues: {
          label: 'We are asking people what factors may be in their backgrounds so we can help people prepare supporting documentation, references and other positive information to the housing authority (check all that apply)? This is NOT to screen you out for a housing opportunity, but rather to help overcome potential admission barriers.',
          number: '8C',
          collection: {
            'A housing authority or housing program terminated your subsidy (i.e. a housing voucher, a public housing unit, etc.)' => 'A housing authority or housing program terminated your subsidy (i.e. a housing voucher, a public housing unit, etc.)',
            'You have been evicted from a legal tenancy where you were the lease holder.' => 'You have been evicted from a legal tenancy where you were the lease holder.',
            'Prior to entering shelter or sleeping outside during this episode of homelessness, you came directly from jail, prison or a pre-release program.' => 'Prior to entering shelter or sleeping outside during this episode of homelessness, you came directly from jail, prison or a pre-release program.',
            'You have been convicted (found guilty of) a violent crime' => 'You have been convicted (found guilty of) a violent crime',
            'You have been convicted (found guilty of) a drug crime' => 'You have been convicted (found guilty of) a drug crime',
            'None of the above' => 'None of the above',
          },
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
        },
        _household_history_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/pathways_household_history_preamble',
        },
        homeless_nights_sheltered: {
          label: 'How many sheltered Boston homeless nights does the participant\'s Window into the Warehouse record show?',
          number: '9A',
        },
        homeless_nights_unsheltered: {
          label: 'How many unsheltered Boston homeless nights does the participant\'s Window into the Warehouse record show?',
          number: '9B',
        },
        _additional_homeless_nights_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/additional_homeless_nights_preamble',
        },
        additional_homeless_nights_sheltered: {
          label: 'Sheltered Boston homeless nights you are adding to their length of time homeless in the warehouse.',
          number: '9C',
        },
        additional_homeless_nights_unsheltered: {
          label: 'Unsheltered Boston homeless nights you are adding to their length of time homeless in the warehouse.',
          number: '9D',
        },
        self_reported_days_verified: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/self_reported_days_verified',
        },
        total_days_homeless_in_the_last_three_years: {
          label: 'Total # of Boston Homeless Nights: (9a+9b+9c+9d)',
          hint: 'Auto calculated',
          number: '9E',
          disabled: true,
        },
        _pathways_next_steps_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_three/next_steps_preamble',
        },
        wait_times_ack: {
          label: 'Wait Times',
          number: '',
          hint: 'Wait times can change from time to time based on how many people are interested, and the openings we have available. We also have a few priority populations we have to serve first if there are limited openings - these are young people, those who have been homeless the longest and people in an unsafe situation.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        not_matched_ack: {
          label: 'What should I do to try to find housing if I am not matched with housing opening?',
          number: '',
          hint: 'We encourage you to think about ways we can help you move in with friends, family, return to safe living situations, or other options since these programs may not always have openings. We encourage you to keep thinking about other ways you may be able to move out of homelessness, like with roommates or people you know at the same time you are applying for affordable housing. If you think of an option, you can always be reassessed to see if we can help with the move in.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        matched_process_ack: {
          label: 'Who Will I Hear From If I Am Matched to a housing opening?',
          number: '',
          hint: 'You may hear from me or any other case managers/contacts you listed here today; you may also hear directly from the housing program, so be sure to return calls or emails even if you do not know the agency. They are going to use all of the contact information you provided us to try to connect with you as quickly as possible. If any of your contact information changes, let me know and I can change it in the assessment.  ',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        response_time_ack: {
          label: 'How Long Will I Have to Respond to a housing opening I am matched with?',
          number: '',
          hint: 'In general, the housing programs will outreach to people who are matched with openings for about two weeks. They will move on to new people who may be interested after two weeks because they have to fill the openings. However, if you are interested after the two weeks, you should still return the call/email/message as you may be able to be matched to another opening at a later date.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        automatic_approval_ack: {
          label: 'Am I automatically approved for the housing openings when I’m matched?',
          number: '',
          hint: 'No. Today we gathered information to help figure out if you’re eligible and match you to your preferences, but the housing programs will actually verify and document eligibility at the time you are referred. All of the programs have different eligibility criteria- our system will do its best to match you with those that you should be eligible for, but there may be times where you are matched, and are not eligible, and will be offered a new opening when one comes up.',
          as: :pretty_boolean,
          wrapper: :custom_boolean,
          required: true,
        },
        notes: {
          label: 'Optional Background Notes from Assessor Staff',
          hint: 'Here staff may write any notes that might be helpful for receiving programs. Notes may entail ways to engage with the participant, ways to find the participant, questions/comments the participant had, safety considerations, best times of day to meet with the participant, or any other important information to pass on.',
          number: '10A',
        },
      }
    end
  end
end
