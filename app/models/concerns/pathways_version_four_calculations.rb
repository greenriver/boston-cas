###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module PathwaysVersionFourCalculations
  extend ActiveSupport::Concern

  included do
    validates_presence_of :entry_date, :hud_assessment_location, :hud_assessment_type, :setting, on: [:create, :update]
    validates_email_format_of :email_addresses, allow_blank: true, if: :pathways?
    validates_format_of :phone_number, with: NonHmisClientsHelper::PHONE_NUMBER_REGEX, message: 'Must be a valid phone number (10 digits).', allow_blank: true, if: :pathways?
    validates :household_size, numericality: { greater_than: 0 }, if: :pathways?
    validates :homeless_nights_sheltered, :additional_homeless_nights_sheltered, :homeless_nights_unsheltered, :additional_homeless_nights_unsheltered, numericality: { less_than_or_equal_to: 1096 }, if: :pathways?
    # The denial_required validation requires the .to_s due to the varchar data type
    validates_inclusion_of :denial_required, in: [[''].to_s], message: 'Cannot be checked unless Barriers to Housing is Yes', allow_blank: false, unless: :housing_barrier?, if: :pathways?
    validates_inclusion_of :service_need_indicators, in: [''], message: 'Cannot be checked unless Service Need Indicator is Yes', allow_blank: false, unless: :service_need?, if: :pathways?

    def title
      return pathways_title if assessment_type.blank?

      assessment_type_options[assessment_type.to_sym][:title]
    end

    def pathways?
      assessment_type.to_sym == :pathways_2024
    end

    def for_matching
      options = case assessment_type.to_sym
      when :pathways_2024
        {
          'PathwaysVersionFourPathways' => pathways_title,
        }
      when :transfer_assessment
        {
          'PathwaysVersionFourTransfer' => transfer_title,
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
      when :pathways_2024
        2 # Housing Needs Assessment
      when :transfer_assessment
        1 # Crisis Needs Assessment
      end
    end

    def tie_breaker_date
      case assessment_type.to_sym
      when :pathways_2024
        entry_date
      when :transfer_assessment
        financial_assistance_end_date
      end
    end

    def family_member
      pregnant_or_parent
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
      when 'Pathways 2024'
        shared.merge(
          {
            income_maximization_assistance_requested: {
              title: 'Interested in income maximization services',
              client_field: :income_maximization_assistance_requested,
            },
          },
        )
      when 'Transfer Assessment 2024'
        shared
      end
    end

    def pathways_assessment_type
      :pathways_2024
    end

    def transfer_assessment_type
      :transfer_assessment
    end

    def pathways_title
      'Pathways 2024'
    end

    def transfer_title
      'Transfer Assessment 2024'
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
      score = 0
      if value.is_a?(Array)
        value.each do |v|
          score += options[v].try(:[], :score) || 0
        end
      else
        score += options[value].try(:[], :score) || 0
      end
      score
    end

    def collection_for(field)
      options = send("#{field}_options")
      options.map do |k, opt|
        [k, opt[:label]]
      end.to_h.invert
    end

    private def times_moved_options
      {
        'none' => {
          label: 'No Moves',
          score: 0,
        },
        'once' => {
          label: 'One move',
          score: 2,
        },
        'two or more' => {
          label: 'Two or more',
          score: 3,
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
          label: 'Client requires little or no assistance with tasks of daily living',
          score: 0,
        },
        'minimal assistance' => {
          label: 'Client requires minimal assistance with daily life functions',
          score: 5,
        },
        'requires assistance minor' => {
          label: 'Client requires some assistance with daily life functions',
          score: 6,
        },
        'requires assistance all' => {
          label: 'Client requires consistent assistance with daily life functions',
          score: 7,
        },
      }
    end

    private def substance_use_options
      {
        false => {
          label: 'No',
          score: 0,
        },
        true => {
          label: 'Yes',
          score: 5,
        },
      }
    end

    private def federal_benefits_options
      {
        false => {
          label: 'No',
          score: 3,
        },
        true => {
          label: 'Yes',
          score: 0,
        },
      }
    end

    private def background_check_issues_options
      {
        'none' => {
          label: 'No evictions',
          score: 0,
        },
        'one' => {
          label: 'Does the client have one eviction within the last 5 years?',
          score: 2,
        },
        'two or more' => {
          label: 'Does the client have more than two evictions within the last 5 years?',
          score: 3,
        },
        'due to disability' => {
          label: 'Were any previous evictions due to a disability or substance use disorder',
          score: 2,
        },
        'prevented documented history' => {
          label: 'Does the client’s length of time homeless prevent documented eviction history?',
          score: 2,
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
      score += score_for(:need_daily_assistance)
      score += score_for(:substance_use)
      score += score_for(:federal_benefits)
      score += score_for(:background_check_issues)
      score += score_for(:times_moved)

      score
    end

    def form_fields
      case title
      when pathways_title
        pathways_fields = pathways_form_fields
        pathways_fields = deidentify_form_fields(pathways_fields) unless identified?
        pathways_fields
      when transfer_title
        transfer_form_fields
      else
        picker_form_fields
      end
    end

    def picker_form_fields
      []
    end

    def deidentify_form_fields(form_fields)
      # Remove the fields with identifying information from the form
      identifying_fields = [:phone_number, :email_addresses]
      form_fields.except(*identifying_fields)
    end

    def transfer_form_fields
      {
        _transfer_assessment_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/transfer_assessment_preamble',
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
        sro_ok: {
          label: 'If you are a single adult, would you consider living in a single room occupancy (SRO)?',
          number: 'Q1',
          collection: {
            'Yes' => true,
            'No' => false,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        disability_section: {
          label: 'Are you seeking any of the following due to a disability? If yes, you may have to provide documentation of disability - related need?',
          number: 'Q2',
          questions: {
            requires_wheelchair_accessibility: {
              label: 'Wheelchair accessible unit',
              number: 'Q2',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            requires_elevator_access: {
              label: 'First floor/elevator (little to no stairs to your unit)',
              number: 'Q2',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            accessibility_other: {
              label: 'Other accessibility',
              number: 'Q2',
            },
          },
        },
        required_number_of_bedrooms: {
          label: 'If you need a bedroom size larger than an SRO, studio or 1 bedroom, select the size below.',
          number: 'Q3',
          collection: {
            '2' => 2,
            '3' => 3,
            '4' => 4,
            '5' => 5,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        housing_barrier_section: {
          label: 'Barriers to Housing:',
          number: 'Q4',
          questions: {
            housing_barrier: {
              label: 'Do you have any of the following histories and/or barriers?',
              number: 'Q4',
              as: :pretty_boolean_group,
              collection: {
                'Yes' => true,
                'No' => false,
              },
            },
            denial_required: {
              label: 'If yes, which ones [OPTIONAL]',
              number: 'Q4',
              collection: {
                Translation.translate('Have been convicted or found guilty of producing methamphetamine on subsidized properties OR') => 'manufacture or production of methamphetamine in household',
                Translation.translate('Have been evicted from a BHA development or have had a BHA voucher terminated within the last three years OR') => 'evicted from or voucher terminated from a BHA',
                Translation.translate('Registered sex offender (level 1,2,3) - lifetime registration (SORI) OR') => 'lifetime sex offender in household',
                Translation.translate('Other (open cases, undocumented, etc.)') => 'other',
              },
              as: :pretty_checkboxes_group,
            },
          },
        },
        need_daily_assistance: {
          label: 'Does client have a physical or mental impairment that substantially limits one or more daily life functions? Daily life functions include: obtaining food/eating, sleeping, physical movement, caring for one’s personal hygiene, and communicating.',
          number: 'Q5',
          as: :select_2,
          collection: collection_for(:need_daily_assistance),
          include_blank: false,
        },
        substance_abuse_problem: {
          label: 'Does the client have a history of substance use disorder that prevents them from living independently without support services?',
          collection: collection_for(:substance_use),
          as: :pretty_boolean_group,
          number: 'Q6',
        },
        federal_benefits: {
          label: 'Does the client qualify for federal benefits?',
          collection: collection_for(:federal_benefits),
          as: :pretty_boolean_group,
          number: 'Q7',
        },
        background_check_issues: {
          label: 'Eviction History',
          number: 'Q8',
          collection: collection_for(:background_check_issues),
          as: :pretty_checkboxes_group,
          input_html: { multiple: true },
        },
        times_moved: {
          label: 'How many times have you moved while enrolled in rapid re-housing?',
          number: 'Q9',
          as: :pretty_boolean_group,
          collection: collection_for(:times_moved),
        },
        financial_assistance_end_date: {
          label: 'Enter date for last day of financial assistance',
          number: 'Q10',
          as: :date_picker,
        },
      }
    end

    def pathways_form_fields
      {
        _pathways_version_four_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/pathways_version_four_preamble',
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
          partial: 'non_hmis_assessments/pathways_version_four/pathways_contact_preamble',
        },
        phone_number: {
          label: 'Client phone number:',
          number: '2C',
        },
        email_addresses: {
          label: 'Client email:',
          number: '2D',
        },
        shelter_section: {
          label: 'Do you have any agencies we could contact to get a hold of you?',
          number: '2E',
          questions: {
            agency_name: {
              label: 'Agency:',
            },
            case_manager_contact_info: {
              label: 'Agency contact name/email/phone:',
              as: :text,
              hint: 'Please provide email address and full name for each contact listed',
            },
          },
        },
        day_location_section: {
          label: 'Are there agencies, shelters, or places you hang out in during the day where we could connect with you?',
          number: '2F',
          questions: {
            day_locations: {
              label: 'Agency:',
            },
            agency_day_contact_info: {
              label: 'Agency contact name/email/phone:',
              as: :text,
              hint: 'Please provide email address and full name for each contact listed',
            },
          },
        },
        night_location_section: {
          label: 'Are there agencies, shelters or places you hang out in during nights or weekends where we could connect with you?',
          number: '2G',
          questions: {
            night_locations: {
              label: 'Agency:',
            },
            agency_night_contact_info: {
              label: 'Agency contact name/email/phone:',
              as: :text,
              hint: 'Please provide email address and full name for each contact listed',
            },
          },
        },
        other_contact: {
          label: 'Are there other ways we could contact you that we have not asked you or thought of yet?',
          number: '2H',
        },
        _household_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/pathways_household_preamble',
        },
        household_size: {
          label: 'What is the total number of people in your household?',
          number: '3A',
          input_html: { class: 'jHouseholdTrigger' },
        },
        pregnant_or_parent: {
          label: 'Are you pregnant or parenting a child under 18?',
          number: '3B',
          as: :pretty_boolean_group,
          collection: {
            'Yes' => true,
            'No' => false,
          },
        },
        household_section: {
          number: '3C',
          label: 'If there is a second adult in your household, is this person also homeless in the City of Boston? (This is only for match coordination. Partner can be assessed and matched separately)',
          questions: {
            partner_warehouse_id: {
              label: 'If yes: assessor - check for Partner Warehouse ID:',
            },
            partner_name: {
              label: 'Partner Name:',
              as: :text,
            },
          },
        },
        sro_ok: {
          label: 'If you are a single adult, would you consider living in a single room occupancy (SRO)?',
          number: '4',
          collection: {
            'Yes' => true,
            'No' => false,
            'Not applicable' => nil,
          },
          as: :pretty_boolean_group,
        },
        required_number_of_bedrooms: {
          label: 'If you need a bedroom size larger than an SRO, studio or 1 bedroom, select the size below',
          number: '5',
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
          number: '6',
          questions: {
            requires_wheelchair_accessibility: {
              label: 'Wheelchair accessible unit',
              number: '6',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            requires_elevator_access: {
              label: 'First floor/elevator (little to no stairs to your unit)',
              number: '6',
              as: :pretty_boolean,
              wrapper: :custom_boolean,
            },
            accessibility_other: {
              label: 'Other accessibility',
              number: '6',
            },
          },
        },
        rrh_desired: {
          label: 'Are you interested Rapid Re-Housing?',
          number: '7',
          as: :pretty_boolean_group,
          collection: {
            'Yes' => true,
            'No' => false,
          },
        },
        housing_barrier_section: {
          label: 'Barriers to Housing:',
          number: 8,
          questions: {
            housing_barrier: {
              label: 'Do you have any of the following histories and/or barriers?',
              number: 8,
              as: :pretty_boolean_group,
              collection: {
                'Yes' => true,
                'No' => false,
              },
            },
            denial_required: {
              label: 'If yes, which ones [OPTIONAL]',
              number: '8',
              collection: {
                Translation.translate('Have been convicted or found guilty of producing methamphetamine on subsidized properties OR') => 'manufacture or production of methamphetamine in household',
                Translation.translate('Have been evicted from a BHA development or have had a BHA voucher terminated within the last three years OR') => 'evicted from or voucher terminated from a BHA',
                Translation.translate('Registered sex offender (level 1,2,3) - lifetime registration (SORI) OR') => 'lifetime sex offender in household',
                Translation.translate('Other (open cases, undocumented, etc.)') => 'other',
              },
              as: :pretty_checkboxes_group,
            },
          },
        },
        service_need_section: {
          label: 'Service Need Indicator:',
          number: '9',
          questions: {
            service_need: {
              label: 'Does any of the following apply to you?',
              number: 9,
              as: :pretty_boolean_group,
              collection: {
                'Yes' => true,
                'No' => false,
              },
            },
            service_need_indicators: {
              label: 'If yes, which ones [OPTIONAL]',
              number: '9',
              collection: {
                Translation.translate("I've faced indefinite restrictions and a history of restrictions from area shelters") => 'restrictions from area shelters',
                Translation.translate('There have been instances where I declined to come inside during dangerous weather') => 'declined to come inside during dangerous weather',
                Translation.translate('My experience of homelessness began in Boston over 10 years ago') => 'homelessness begain 10 years ago',
                Translation.translate('I have a criminal record (CORI) or ongoing legal cases') => 'criminal record (CORI) or ongoing legal cases',
                Translation.translate('I am on a High Utilizer of Emergency Services (HUES) list.') => 'on the HUES list',
                Translation.translate('I am or have been at risk of engaging in high-risk and exploitative situations, such as sex trafficking.') => 'at risk of engaging in high-risk and exploitative situations',
                Translation.translate('In the last 3 years, I have been housed but lost housing') => 'lost housing in the last 3 years',
                Translation.translate('I have a history of extended stays (12+ months) in medical respite and other inpatient treatment facilities') => 'history of extended stas in inpatient treatment facilities',
                Translation.translate('In the last 2 years, I have had at least one Section 12 or 35 and/or have been involuntarily committed') => 'involuntarily committed and 1+ Section 12 or 35 in the last 2 years',
              },
              as: :pretty_checkboxes_group,
            },
          },
        },
        _household_history_preamble: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/pathways_household_history_preamble',
        },
        homeless_nights_sheltered_section: {
          number: '10A',
          label: 'Length of Time Homeless (Sheltered) - Warehouse:',
          questions: {
            homeless_nights_sheltered: {
              label: 'Check the client’s record in the Warehouse; how many sheltered homeless nights in a shelter in the last 3 years does the client have?',
            },
          },
        },
        additional_homeless_nights_sheltered_section: {
          number: '10B',
          label: 'Length of Time Homeless (Sheltered) - Non-HMIS:',
          questions: {
            additional_homeless_nights_sheltered: {
              label: 'Does the client have additional sheltered nights outside of HMIS/Warehouse? (At a shelter or hotel/motel paid by government or charity.)',
            },
          },
        },
        homeless_nights_unsheltered_section: {
          number: '10C',
          label: 'Length of Time Homeless (Unsheltered) - Warehouse:',
          questions: {
            homeless_nights_unsheltered: {
              label: 'Check the client’s record in the Warehouse; how many unsheltered homeless nights in the last 3 years does the client have?',
            },
          },
        },
        additional_homeless_nights_unsheltered_section: {
          number: '10D',
          label: 'Length of Time Homeless (Unsheltered) - Non-HMIS:',
          questions: {
            additional_homeless_nights_unsheltered: {
              label: 'Does the client have additional unsheltered  nights outside of HMIS/Warehouse? (Place not meant for human habitation/outside/car/station.)',
            },
          },
        },
        self_reported_days_verified: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/self_reported_days_verified',
        },
        total_homeless_nights_sheltered: {
          label: 'Total # of Sheltered Nights:',
          hint: 'Auto calculated',
          number: '10E',
          disabled: true,
        },
        total_homeless_nights_unsheltered: {
          label: 'Total # of Unsheltered Nights:',
          hint: 'Auto calculated',
          number: '10F',
          disabled: true,
        },
        total_days_homeless_in_the_last_three_years: {
          label: 'Total # of Boston Homeless Nights: (Cannot exceed 1096)',
          hint: 'Auto calculated',
          number: '10G',
          disabled: true,
        },
        _household_history_epilogue: {
          as: :partial,
          partial: 'non_hmis_assessments/pathways_version_four/pathways_household_history_epilogue',
        },
      }
    end
  end
end
