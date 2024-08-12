###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class NonHmisAssessment < ActiveRecord::Base
  include ApplicationHelper
  include ArelHelper

  has_paper_trail
  acts_as_paranoid

  attr_accessor :youth_rrh_aggregate, :dv_rrh_aggregate, :date_of_birth
  attr_writer :total_days_homeless_in_the_last_three_years

  belongs_to :non_hmis_client
  belongs_to :user
  belongs_to :agency, optional: true

  after_find :populate_aggregates

  before_save :update_assessment_score

  scope :limitable_pathways, -> do
    where(type: limited_assessment_types)
  end

  scope :visible_by, ->(user) do
    where(non_hmis_client_id: NonHmisClient.visible_to(user).select(:id))
  end

  scope :editable_by, ->(user) do
    where(agency_id: user.agency_id)
  end

  def self.to_class(name)
    # TODO: this doesn't work for PathwaysVersionThree
    # Pathways V3 has multiple assessment types we need to deal with
    name = name&.gsub('VersionThreePathways', 'VersionThree')&.gsub('VersionThreeTransfer', 'VersionThree')
    klass_name = known_assessment_types.detect { |m| m == name } || 'IdentifiedClientAssessment'
    klass_name.constantize
  end

  def self.known_assessment_types
    [
      'IdentifiedClientAssessment',
      'DeidentifiedClientAssessment',
      'IdentifiedPathwaysAssessment',
      'DeidentifiedPathwaysAssessment',
      'IdentifiedCovidPathwaysAssessment',
      'DeidentifiedCovidPathwaysAssessment',
      'IdentifiedPathwaysVersionThree',
      'DeidentifiedPathwaysVersionThree',
      'IdentifiedPathwaysVersionFour',
      'DeidentifiedPathwaysVersionFour',
      'IdentifiedTcHat',
      'DeidentifiedTcHat',
      'IdentifiedCeAssessment',
    ].freeze
  end

  def self.limited_assessment_types
    [
      'IdentifiedCovidPathwaysAssessment',
      'DeidentifiedCovidPathwaysAssessment',
    ]
  end

  def self.known_assessments_for_matching
    {}.merge(IdentifiedClientAssessment.new.for_matching).
      merge(DeidentifiedClientAssessment.new.for_matching).
      merge(IdentifiedPathwaysAssessment.new.for_matching).
      merge(DeidentifiedPathwaysAssessment.new.for_matching).
      merge(IdentifiedCovidPathwaysAssessment.new.for_matching).
      merge(DeidentifiedCovidPathwaysAssessment.new.for_matching).
      merge(IdentifiedPathwaysVersionThree.new(assessment_type: :pathways_2021).for_matching).
      merge(IdentifiedPathwaysVersionThree.new(assessment_type: :transfer_assessment).for_matching).
      merge(DeidentifiedPathwaysVersionThree.new(assessment_type: :pathways_2021).for_matching).
      merge(DeidentifiedPathwaysVersionThree.new(assessment_type: :transfer_assessment).for_matching).
      merge(IdentifiedPathwaysVersionFour.new(assessment_type: :pathways_2024).for_matching).
      merge(IdentifiedPathwaysVersionFour.new(assessment_type: :transfer_assessment).for_matching).
      merge(DeidentifiedPathwaysVersionFour.new(assessment_type: :pathways_2024).for_matching).
      merge(DeidentifiedPathwaysVersionFour.new(assessment_type: :transfer_assessment).for_matching).
      merge(IdentifiedTcHat.new.for_matching).
      merge(DeidentifiedTcHat.new.for_matching).
      merge(IdentifiedCeAssessment.new.for_matching).
      merge(ImportedClientAssessment.new.for_matching).
      freeze
  end

  def self.title_from_type_for_matching(type_for_matching)
    known_assessments_for_matching[type_for_matching]
  end

  def self.declassify_title(name)
    return unless name.present?

    name.gsub(' - Identified', '').gsub(' - Deidentified', '')
  end

  def title
    'Non-HMIS Assessment'
  end

  def hide_confidential?(user)
    return false if agency_id.blank?

    user.agency_id != agency_id
  end

  def update_assessment_score!
    update_assessment_score
    save
    non_hmis_client.save
  end

  def pathways_v3?
    type.include?('PathwaysVersionThree')
  end

  def pathways_v4?
    type.include?('PathwaysVersionFour')
  end

  def total_days_homeless_in_the_last_three_years
    if pathways_v4?
      total = total_homeless_nights_sheltered + total_homeless_nights_unsheltered
      total.clamp(0, 1096)
    elsif pathways_v3?
      warehouse_days = (days_homeless_in_the_last_three_years || 0) +
        (homeless_nights_sheltered || 0) +
        (homeless_nights_unsheltered || 0)
      extra_days = (additional_homeless_nights || 0) +
        (additional_homeless_nights_sheltered || 0) +
        (additional_homeless_nights_unsheltered || 0)
      extra_days = extra_days > 548 ? 548 : extra_days unless self_reported_days_verified?
      total = warehouse_days + extra_days
      total > 1096 ? 1096 : total
    else
      (days_homeless_in_the_last_three_years || 0) +
      (additional_homeless_nights || 0) +
      (additional_homeless_nights_sheltered || 0) +
      (homeless_nights_sheltered || 0) +
      (additional_homeless_nights_unsheltered || 0) +
      (homeless_nights_unsheltered || 0)
    end
  end

  def total_homeless_nights_sheltered
    if pathways_v4?
      warehouse_sheltered = (homeless_nights_sheltered || 0) # rubocop:disable Style/RedundantParentheses
      extra_nights_sheltered = (additional_homeless_nights_sheltered || 0) # rubocop:disable Style/RedundantParentheses
      extra_nights_unsheltered = (additional_homeless_nights_unsheltered || 0) # rubocop:disable Style/RedundantParentheses
      # If a client has more than 548 self-reported days (combination of sheltered and unsheltered)
      # and does not have a verification uploaded, count unsheltered days first, then count sheltered days UP TO 548.
      # If the self reported days are verified, use the provided amounts.
      unless self_reported_days_verified
        # 1. Cap the total unsheltered at 548 days if it is greater than this amount.
        extra_nights_unsheltered = extra_nights_unsheltered > 548 ? 548 : extra_nights_unsheltered
        # 2. Find the maximum amount of sheltered days to count based on the total unsheltered days.
        #    The combination of the two cannot exeed 548.
        max_sheltered = [548 - extra_nights_unsheltered, 0].max
        # 3. Cap the sheltered days counted at the calculated max if it exceeds that amount.
        extra_nights_sheltered = extra_nights_sheltered > max_sheltered ? max_sheltered : extra_nights_sheltered
      end
      (warehouse_sheltered + extra_nights_sheltered).clamp(0, 1096)
    else
      (homeless_nights_sheltered || 0) + (additional_homeless_nights_sheltered || 0)
    end
  end

  def total_homeless_nights_unsheltered
    if pathways_v4?
      warehouse_unsheltered = (homeless_nights_unsheltered || 0) # rubocop:disable Style/RedundantParentheses
      extra_nights_unsheltered = (additional_homeless_nights_unsheltered || 0) # rubocop:disable Style/RedundantParentheses
      # If the self reported days are verified, use the provided amounts.
      unless self_reported_days_verified
        # If they are not verified, cap the total unsheltered at 548.
        extra_nights_unsheltered = extra_nights_unsheltered > 548 ? 548 : extra_nights_unsheltered
      end
      (warehouse_unsheltered + extra_nights_unsheltered).clamp(0, 1096)
    else
      (homeless_nights_unsheltered || 0) + (additional_homeless_nights_unsheltered || 0)
    end
  end

  private def update_assessment_score
    self.assessment_score = calculated_score if respond_to? :calculated_score

    return unless non_hmis_client

    non_hmis_client.assign_attributes(
      assessment_score: assessment_score,
      assessed_at: updated_at || Time.current,
    )
  end

  def tie_breaker_date
    nil # default, override when appropriate
  end

  private def populate_aggregates
    if youth_rrh_desired? && rrh_desired?
      self.youth_rrh_aggregate = 'both'
    elsif youth_rrh_desired?
      self.youth_rrh_aggregate = 'youth'
    elsif rrh_desired?
      self.youth_rrh_aggregate = 'adult'
    end

    if dv_rrh_desired? && rrh_desired?
      self.dv_rrh_aggregate = 'both'
    elsif dv_rrh_desired?
      self.dv_rrh_aggregate = 'dv'
    elsif rrh_desired?
      self.dv_rrh_aggregate = 'non-dv'
    end
  end

  def default?
    true
  end

  def self.checkmark(boolean)
    boolean ? '✓' : ''
  end

  def non_hmis_assessment_params
    [
      :entry_date,
      :assessment_score,
      :vispdat_score,
      :vispdat_priority_score,
      :veteran,
      :veteran_status,
      :actively_homeless,
      :days_homeless_in_the_last_three_years,
      :date_days_homeless_verified,
      :who_verified_days_homeless,
      :rrh_desired,
      :youth_rrh_desired,
      :rrh_assessment_contact_info,
      :income_maximization_assistance_requested,
      :income_total_monthly,
      :pending_subsidized_housing_placement,
      :family_member,
      :calculated_chronic_homelessness,
      :income_total_annual,
      :disabling_condition,
      :physical_disability,
      :developmental_disability,
      :domestic_violence,
      :interested_in_set_asides,
      :required_number_of_bedrooms,
      :required_minimum_occupancy,
      :requires_wheelchair_accessibility,
      :requires_elevator_access,
      :youth_rrh_aggregate,
      :dv_rrh_aggregate,
      :dv_rrh_desired,
      :veteran_rrh_desired,
      :rrh_th_desired,
      :sro_ok,
      :other_accessibility,
      :disabled_housing,
      :documented_disability,
      :evicted,
      :ssvf_eligible,
      :health_prioritized,
      :hiv_aids,
      :is_currently_youth,
      :case_manager_contact_info,
      :shelter_name,
      :phone_number,
      :email_addresses,
      :mailing_address,
      :agency_name,
      :day_locations,
      :agency_day_contact_info,
      :night_locations,
      :agency_night_contact_info,
      :other_contact,
      :household_size,
      :hoh_age,
      :current_living_situation,
      :pending_housing_placement_type,
      :pending_housing_placement_type_other,
      :maximum_possible_monthly_rent,
      :possible_housing_situation,
      :possible_housing_situation_other,
      :no_rrh_desired_reason,
      :no_rrh_desired_reason_other,
      :accessibility_other,
      :hiv_housing,
      :medical_care_last_six_months,
      :intensive_needs_other,
      :additional_homeless_nights,
      :homeless_night_range,
      :homeless_nights_sheltered,
      :homeless_nights_unsheltered,
      :additional_homeless_nights_sheltered,
      :additional_homeless_nights_unsheltered,
      :self_reported_days_verified,
      :notes,
      :children_info,
      :chronic_health_condition,
      :fifty_five_plus,
      :have_tenant_voucher,
      :interested_in_disabled_housing,
      :mental_health_problem,
      :older_than_65,
      :one_br_ok,
      :set_asides_housing_status,
      :set_asides_resident,
      :sixty_two_plus,
      :studio_ok,
      :substance_abuse_problem,
      :voucher_agency,
      :assessment_type,
      :times_moved,
      :health_severity,
      :ever_experienced_dv,
      :eviction_risk,
      :need_daily_assistance,
      :any_income,
      :income_source,
      :positive_relationship,
      :legal_concerns,
      :healthcare_coverage,
      :childcare,
      :household_members,
      :financial_assistance_end_date,
      :wait_times_ack,
      :not_matched_ack,
      :matched_process_ack,
      :response_time_ack,
      :automatic_approval_ack,
      :outreach_name,
      :setting,
      :hud_assessment_location,
      :hud_assessment_type,
      :tc_hat_assessment_level,
      :tc_hat_household_type,
      :ongoing_support_reason,
      :ongoing_support_housing_type,
      :lifetime_sex_offender,
      :state_id,
      :birth_certificate,
      :social_security_card,
      :has_tax_id,
      :tax_id,
      :roommate_ok,
      :full_time_employed,
      :can_work_full_time,
      :willing_to_work_full_time,
      :why_not_working,
      :rrh_successful_exit,
      :th_desired,
      :drug_test,
      :heavy_drug_use,
      :sober,
      :willing_case_management,
      :employed_three_months,
      :living_wage,
      :site_case_management_required,
      :ongoing_case_management_required,
      :open_case,
      :foster_care,
      :currently_fleeing,
      :dv_date,
      :tc_hat_ed_visits,
      :tc_hat_hospitalizations,
      :sixty_plus,
      :cirrhosis,
      :end_stage_renal_disease,
      :heat_stroke,
      :blind,
      :tri_morbidity,
      :high_potential_for_victimization,
      :self_harm,
      :medical_condition,
      :psychiatric_condition,
      :housing_preferences_other,
      :tc_hat_apartment,
      :tc_hat_tiny_home,
      :tc_hat_rv,
      :tc_hat_house,
      :tc_hat_mobile_home,
      :tc_hat_total_housing_rank,
      :days_homeless,
      :pregnancy_status,
      :pregnant_under_28_weeks,
      :pregnant_or_parent,
      :tc_hat_single_parent_child_over_ten,
      :tc_hat_legal_custody,
      :tc_hat_will_gain_legal_custody,
      :housing_barrier,
      :service_need,
      :partner_name,
      :partner_warehouse_id,
      :share_information_permission,
      :jail_caused_episode,
      :income_caused_episode,
      :ipv_caused_episode,
      :violence_caused_episode,
      :chronic_health_caused_episode,
      :acute_health_caused_episode,
      :idd_caused_episode,
      strengths: [],
      challenges: [],
      tc_hat_client_history: [],
      housing_preferences: [],
      housing_rejected_preferences: [],
      denial_required: [],
      neighborhood_interests: [],
      provider_agency_preference: [],
      affordable_housing: [],
      high_covid_risk: [],
      service_need_indicators: [],
      intensive_needs: [],
      background_check_issues: [],
      household_members: {},
    ].freeze
  end

  def requires_assessment_type_choice?
    false
  end

  def relationships_to_hoh
    {
      2 => 'Child',
      3 => 'Spouse or partner',
      4 => 'Other relative',
      5 => 'Unrelated household member',
    }
  end

  def hud_assessment_types
    {
      'Phone' => 1,
      'Virtual' => 2,
      'In Person' => 3,
    }
  end

  def hud_assessment_locations
    return [] unless Warehouse::Base.enabled?

    Warehouse::AssessmentAnswerLookup.
      for_column(:assessment_location).
      order(response_text: :asc).
      pluck(:response_text, :response_code).to_h
  end

  # Override as necessary
  def hud_assessment_level
    2 # Housing Needs Assessment
  end

  def lockable_fields
    []
  end

  def locked?
    false
  end

  # Do nothing, override as necessary
  def lock
  end

  def in_lock_grace_period?
    true
  end

  def self.export_headers(assessment_name)
    export_fields(assessment_name).map { |_, config| config[:title] }
  end

  # Add or override as necessary for each assessment type
  def self.export_fields(_assessment_name)
    {
      first_name: {
        title: 'First Name',
        client_field: :first_name,
      },
      last_name: {
        title: 'Last Name',
        client_field: :last_name,
      },
      middle_name: {
        title: 'Middle Name',
        client_field: :middle_name,
      },
      email: {
        title: 'Email',
        client_field: :email,
      },
      phone_number: {
        title: 'Phone',
        client_field: :cellphone,
      },
      date_of_birth: {
        title: 'Date of Birth',
        client_field: :date_of_birth,
      },
      age: {
        title: 'Age',
        client_field: :age,
      },
      disabling_condition: {
        title: 'Disabling Condition',
        client_field: :disabling_condition_for_export,
      },
      dv: {
        title: 'DV',
        client_field: :dv_for_export,
      },
      line_1: {
        title: 'Address Line 1',
        client_field: :line_1_for_export,
      },
      line_2: {
        title: 'Address Line 2',
        client_field: :line_2_for_export,
      },
      city: {
        title: 'City',
        client_field: :city_for_export,
      },
      state: {
        title: 'State',
        client_field: :state_for_export,
      },
      postal_code: {
        title: 'ZIP Code',
        client_field: :postal_code_for_export,
      },
      primary_contact_first_name: {
        title: 'Caseworker First Name',
        client_field: :primary_contact_first_name,
      },
      primary_contact_last_name: {
        title: 'Caseworker Last Name',
        client_field: :primary_contact_last_name,
      },
      primary_contact_user_agency_name: {
        title: 'Caseworker Organization Name',
        client_field: :primary_contact_user_agency_name,
      },
      primary_contact_email: {
        title: 'Caseworker Email',
        client_field: :primary_contact_email,
      },
      primary_contact_phone: {
        title: 'Caseworker Phone',
        client_field: :primary_contact_phone,
      },
      secondary_contact_first_name: {
        title: 'Additional Caseworker First Name',
        client_field: :secondary_contact_first_name,
      },
      secondary_contact_last_name: {
        title: 'Additional Caseworker Last Name',
        client_field: :secondary_contact_last_name,
      },
      secondary_contact_email: {
        title: 'Additional Caseworker Email',
        client_field: :secondary_contact_email,
      },
      secondary_contact_phone: {
        title: 'Additional Caseworker Phone',
        client_field: :secondary_contact_phone,
      },
      client_assessor_first_name: {
        title: 'Assessor First Name',
        client_field: :assessor_first_name,
      },
      client_assessor_last_name: {
        title: 'Assessor Last Name',
        client_field: :assessor_last_name,
      },
      client_assessor_email: {
        title: 'Assessor Email',
        client_field: :assessor_email,
      },
      client_assessor_phone: {
        title: 'Assessor Phone',
        client_field: :assessor_phone,
      },
      warehouse_id: {
        title: 'Client Warehouse ID',
        client_field: :warehouse_id,
      },
      id: {
        title: 'CAS Client ID',
        client_field: :id,
      },
      assessment_score: {
        title: 'Assessment Score',
        client_field: :assessment_score,
      },
      tie_breaker_date: {
        title: 'Tie Breaker Date',
        client_field: :tie_breaker_date,
      },
      family_member: {
        title: 'Family',
        client_field: :family_member_for_export,
      },
      income_total_monthly: {
        title: 'Monthly Income',
        client_field: :income_total_monthly,
      },
    }
  end

  def child_in_household
    false # Override as appropriate
  end

  def form_field_labels
    return [] unless respond_to?(:form_fields)

    [].tap do |labels|
      form_fields.each do |_, field|
        # If there are sub-questions, there will not be answers at this level
        if field[:questions]
          field[:questions].each do |_, f|
            labels << f[:label]
          end
        else
          labels << field[:label]
        end
      end
    end
  end

  def form_field_values
    return [] unless respond_to?(:form_fields)

    [].tap do |values|
      form_fields.each do |name, field|
        # If there are sub-questions, there will not be answers at this level
        if ! field[:questions]
          next if field[:as] == :partial

          val = send(name)
          values << if val.is_a?(Array)
            val = val.select(&:present?)
            field[:collection].invert.values_at(*val).to_sentence
          elsif field[:collection].present?
            field[:collection].invert[val]
          elsif val.in?([true, false])
            yes_no(val)
          else
            val
          end
        else
          field[:questions].each do |sub_name, f|
            next if f[:as] == :partial

            val = send(sub_name)
            values << if val.is_a?(Array)
              val = val.select(&:present?)
              f[:collection].invert.values_at(*val).to_sentence if val.present?
            elsif field[:collection].present?
              field[:collection].invert[val]
            elsif val.in?([true, false])
              yes_no(val)
            else
              val
            end
          end
        end
      end
    end
  end
end
