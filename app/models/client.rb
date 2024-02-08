###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'street_address'
class Client < ApplicationRecord
  before_create :assign_tie_breaker

  include SubjectForMatches
  include MatchArchive
  include Availability
  include HudDemographics

  has_paper_trail
  acts_as_paranoid

  belongs_to :ethnicity, foreign_key: :ethnicity_id, primary_key: :numeric
  belongs_to :veteran_status, foreign_key: :veteran_status_id, primary_key: :numeric

  belongs_to :project_client, primary_key: :client_id, foreign_key: :id, optional: true
  has_many :building_clients

  # all contacts
  has_many :client_contacts, dependent: :destroy, inverse_of: :client
  has_many :contacts, through: :client_contacts

  has_many :regular_client_contacts, -> { where regular: true },
           class_name: 'ClientContact'
  has_many :regular_contacts,
           through: :regular_client_contacts,
           source: :contact

  has_many :shelter_agency_client_contacts, -> { where shelter_agency: true },
           class_name: 'ClientContact'
  has_many :shelter_agency_contacts,
           through: :shelter_agency_client_contacts,
           source: :contact

  has_many :dnd_staff_client_contacts, -> { where dnd_staff: true },
           class_name: 'ClientContact'
  has_many :dnd_staff_contacts,
           through: :dnd_staff_client_contacts,
           source: :contact

  has_many :housing_subsidy_admin_client_contacts, -> { where housing_subsidy_admin: true },
           class_name: 'ClientContact'
  has_many :housing_subsidy_admin_contacts,
           through: :housing_subsidy_admin_client_contacts,
           source: :contact

  has_many :hsp_client_contacts, -> { where hsp: true },
           class_name: 'ClientContact'
  has_many :hsp_contacts,
           through: :hsp_client_contacts,
           source: :contact

  has_many :ssp_client_contacts, -> { where ssp: true },
           class_name: 'ClientContact'
  has_many :ssp_contacts,
           through: :ssp_client_contacts,
           source: :contact

  has_many :do_client_contacts, -> { where do: true },
           class_name: 'ClientContact'
  has_many :do_contacts,
           through: :do_client_contacts,
           source: :contact

  has_many :client_notes, inverse_of: :client

  has_many :unavailable_as_candidate_fors

  has_many :reporting_decisions, class_name: 'Reporting::Decisions', foreign_key: :cas_client_id

  has_many :referral_events, class_name: 'Warehouse::ReferralEvent', inverse_of: :client
  has_many :external_referrals, inverse_of: :client

  validates :ssn, length: { maximum: 9 }

  scope :visible_by, ->(user) do
    if user&.can_view_all_clients? || user&.can_edit_all_clients?
      current_scope || all
    elsif user&.can_edit_clients_based_on_rules? && user&.requirements&.exists?
      client_scope = current_scope || all
      user.requirements.each do |requirement|
        client_scope = client_scope.merge(requirement.clients_that_fit(client_scope))
      end
      client_scope
    else
      none
    end
  end

  scope :editable_by, ->(user) do
    if user.can_edit_all_clients? || user.can_edit_clients_based_on_rules?
      visible_by(user)
    else
      none
    end
  end

  def editable_by?(user)
    Client.editable_by(user).where(id: id).exists?
  end

  scope :parked, -> do
    joins(:unavailable_as_candidate_fors)
  end

  scope :available_for_matching, ->(match_route) do
    # anyone who hasn't been matched fully, isn't parked
    available_clients = available.available_as_candidate(match_route)
    # and unless allowed by the route, isn't active in another match
    if match_route.should_prevent_multiple_matches_per_client
      available_clients.where.not(
        id: ClientOpportunityMatch.active.
          on_route(match_route).
          joins(:client).select(arel_table[:id]),
      )
    else
      available_clients
    end
  end

  scope :available_as_candidate, ->(match_route) do
    where.not(id: UnavailableAsCandidateFor.for_route(match_route).select(:client_id))
  end

  scope :active_in_match, -> {
    joins(:client_opportunity_matches).merge(ClientOpportunityMatch.active)
  }
  scope :available, -> {
    where(available: true)
  }
  scope :unavailable, -> {
    where(available: false)
  }
  scope :available, -> do
    where(available: true)
  end

  scope :unavailable_in, ->(route) do
    joins(:unavailable_as_candidate_fors).merge(UnavailableAsCandidateFor.for_route(route))
  end
  # scope :fully_matched, -> {
  #   where(available_candidate: false).
  #   where.not(id: active_in_match.select(:id))
  # }

  scope :veteran, -> { where(veteran: true) }
  scope :non_veteran, -> { where(veteran: false) }
  scope :confidential, -> { where(confidential: true) }
  scope :non_confidential, -> { where(confidential: false) }
  scope :full_release, -> { where(housing_release_status: 'Full HAN Release') }

  scope :active_cohorts, ->(limit) do
    limit = Array.wrap(limit).map(&:to_s).reject(&:blank?).map(&:to_i)
    where('active_cohort_ids @> ANY(ARRAY [?]::jsonb[])', limit.to_s)
  end

  scope :search_alternate_name, ->(name) do
    arel_table[:alternate_names].lower.matches("%#{name.downcase}%")
  end
  scope :search_first_name, ->(name) do
    arel_table[:first_name].lower.matches("#{name.downcase}%")
  end
  scope :search_last_name, ->(name) do
    arel_table[:last_name].lower.matches("#{name.downcase}%")
  end
  scope :search_last_four, ->(last4) do
    arel_table[:ssn].matches("%#{last4}")
  end

  scope :text_search, ->(text) do
    return none unless text.present?

    text.strip!
    sa = arel_table
    # numeric = /[\d-]+/.match(text).try(:[], 0) == text
    date = /\d\d?\/\d\d?\/\d\d\d\d/.match(text).try(:[], 0) == text
    social = /\d\d\d-?\d\d-?\d\d\d\d/.match(text).try(:[], 0) == text
    last_four = /\d{4}/.match(text).try(:[], 0) == text
    # Explicitly search for only last, first if there's a comma in the search
    if text.include?(',')
      last, first = text.split(',').map(&:strip)
      where = search_last_name(last).or(search_alternate_name(last)) if last.present?
      if last.present? && first.present?
        where = where.and(search_first_name(first)).or(search_alternate_name(first))
      elsif first.present?
        where = search_first_name(first).or(search_alternate_name(first))
      end
    # Explicitly search for "first last"
    elsif text.include?(' ')
      first, last = text.split(' ').map(&:strip)
      where = search_first_name(first).
        and(search_last_name(last)).
        or(search_alternate_name(first)).
        or(search_alternate_name(last))
    # Explicitly search for a PersonalID
    elsif social
      where = sa[:ssn].eq(text.gsub('-', ''))
    elsif last_four
      where = search_last_four(text)
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

  def full_name
    [first_name, middle_name, last_name, name_suffix].select(&:present?).join(' ')
  end
  alias name full_name

  def client_name_for_user user, hidden:
    if user.can_view_all_clients? || accessible_by_user?(user)
      hide_name(name: full_name, hidden: hidden)
    else
      client_name_for_contact user.contact, hidden: hidden
    end
  end

  def client_name_for_contact contact, hidden:
    if contact.user_can_view_all_clients?
      hide_name(name: full_name, hidden: hidden)
    elsif project_client.non_hmis_client_identifier.blank?
      '(name withheld)'
    else
      hide_name(name: project_client.non_hmis_client_identifier, hidden: hidden)
    end
  end

  def hide_name name:, hidden:
    hidden ? '(name hidden)' : name
  end

  def client_identifier_label contact
    if project_client&.non_hmis_client_identifier.present? && !contact.user_can_view_all_clients?
      'Client Identifier'
    else
      'Client Name'
    end
  end

  def default_client_contacts
    @default_client_contacts ||= ClientContacts.new client: self
  end

  def self.prioritized(match_route, scope)
    match_route.match_prioritization.prioritization_for_clients(scope)
  end

  # A random number for prioritization that require a tie-breaker
  def assign_tie_breaker
    self.tie_breaker = rand
  end

  def self.add_missing_tie_breakers
    result = Client.where(tie_breaker: nil).update_all(Arel.sql('tie_breaker = random()'))
    log "Updated #{result} clients with missing tie_breakers"
  end

  def self.ready_to_match match_route:
    available_as_candidate(match_route).matchable
  end

  def self.max_candidate_matches
    1
  end

  def self.randomize_pii
    all.each do |c|
      c.first_name = Faker::Name.first_name
      c.middle_name = Faker::Boolean.boolean(0.10) ? Faker::Name.last_name : nil
      c.last_name = Faker::Name.last_name
      c.name_suffix = ''
      c.ssn = Faker::Number.number(9)
      c.date_of_birth = Faker::Date.between(80.years.ago, 25.years.ago)
      c.homephone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.cellphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.workphone = Faker::Boolean.boolean(0.5) ? Faker::PhoneNumber.cell_phone : nil
      c.pager = ''
      c.email = ''
      c.save(validate: false)
    end
  end

  def self.accessible_by_user(user)
    visible_by(user)
  end

  def accessible_by_user?(user)
    self.class.where(id: id).visible_by(user).exists?
  end

  def non_hmis?
    NonHmisClient.joins(:client).merge(Client.where(id: id)).exists?
  end

  def non_hmis_client
    NonHmisClient.joins(:client).merge(Client.where(id: id))&.first
  end

  def merged_with_name
    c = Client.find(merged_into)
    c.full_name
  end

  def previously_merged?
    count = Client.where(merged_into: id).pluck(id).length
    return true if count.positive?

    false
  end

  def self.age date:, dob:
    return unless date.present? && dob.present?

    age = date.year - dob.year
    age -= 1 if dob > date.years_ago(age)
    return age
  end

  def age date = Date.current
    return unless date_of_birth.present?

    date = date.to_date
    dob = date_of_birth.to_date
    self.class.age(date: date, dob: dob)
  end
  alias age_on age

  def cohorts
    return [] unless Warehouse::Base.enabled?

    Warehouse::Cohort.visible_in_cas.where(id: active_cohort_ids)
  end

  def rank_for_tag match_route:
    tag_id = match_route.tag_id
    tags.try(:[], tag_id.to_s)
  end

  def prioritized_matches
    o_t = Opportunity.arel_table
    client_opportunity_matches.joins(:opportunity).order(o_t[:matchability].asc)
  end

  def housing_history
    # client_opportunity_matches.inspect
  end

  def match_for_opportunity(opportunity)
    active_matches.detect { |m| m.opportunity_id == opportunity.id }
  end

  # NOTE: this uses any? instead of exists? so that data can pre pre-loaded in batches
  def active_in_match?
    active_matches.any?
  end

  def available_as_candidate_for_any_route?
    (
      MatchRoutes::Base.available.pluck(:type) -
      UnavailableAsCandidateFor.where(client_id: id).distinct.pluck(:match_route_type)
    ).any?
  end

  def make_available_in match_route:
    route_name = MatchRoutes::Base.route_name_from_route(match_route)
    UnavailableAsCandidateFor.where(client_id: id, match_route_type: route_name).destroy_all
  end

  def make_available_in_all_routes
    UnavailableAsCandidateFor.where(client_id: id).destroy_all
  end

  private def default_unavailable_expiration_date
    days = Config.get(:unavailable_for_length)
    return nil unless days.present? && days.positive?

    Date.current + days.days
  end

  def make_unavailable_in(match_route:, expires_at: default_unavailable_expiration_date)
    route_name = MatchRoutes::Base.route_name_from_route(match_route)

    un = unavailable_as_candidate_fors.where(match_route_type: route_name).first_or_create
    un.update(expires_at: expires_at)
  end

  def make_unavailable_in_all_routes(expires_at: default_unavailable_expiration_date)
    MatchRoutes::Base.all_routes.each do |route|
      make_unavailable_in(match_route: route, expires_at: expires_at)
    end
  end

  # cancel_specific must be a match object
  def unavailable(permanent: false, contact_id: nil, cancel_all: false, cancel_specific: false, expires_at: default_unavailable_expiration_date)
    Client.transaction do
      update(available: false) if permanent

      if cancel_all
        # Cancel any active matches
        client_opportunity_matches.active.each do |active_match|
          opportunity = active_match.opportunity
          active_match.canceled!
          MatchEvents::Parked.create!(
            match_id: active_match.id,
            contact_id: contact_id,
          )
          opportunity.update(available_candidate: true)
        end
        # Delete any non-active open matches
        client_opportunity_matches.open.each(&:delete)
        # Prevent any new matches for this client
        # This will re-queue the client once the date is passed
        make_unavailable_in_all_routes(expires_at: expires_at)
      end

      if cancel_specific
        # remove from specific match and proposed on same route
        match = cancel_specific
        opportunity = match.opportunity
        route = match.match_route
        match.canceled! # note canceled! makes the client available in the route
        Notifications::MatchCanceled.create_for_match! match
        MatchEvents::Parked.create!(
          match_id: match.id,
          contact_id: contact_id,
        )
        opportunity.update(available_candidate: true)
        # Delete any non-active open matches
        client_opportunity_matches.on_route(route).proposed.each(&:delete)
        make_unavailable_in(match_route: route, expires_at: expires_at)
      end
    end
    Matching::RunEngineJob.perform_later
  end

  def remote_id
    @remote_id ||= project_client&.id_in_data_source.presence
  end

  def remote_data_source_id
    @remote_data_source_id ||= project_client&.data_source_id
  end

  def remote_data_source
    @remote_data_source ||= DataSource.find(remote_data_source_id) rescue false # rubocop:disable Style/RescueModifier
  end

  def remote_client_visible_to?(user)
    return true unless project_client.is_deidentified? || project_client.is_identified?
    return true if NonHmisClient.visible_to(user).where(id: remote_id).exists?

    false
  end

  # Link to the warehouse or other authoritative data source
  # urls should be placed in `data_sources.client_url` and can include :client_id: which will
  # be replaced with Client.remote_id
  # Default URL will use the warehouse setting from the site config
  def data_source_path
    return unless remote_data_source_id && remote_id

    # FIXME: if client....identified? change url
    internal_url = DataSource.where(id: remote_data_source_id).pluck(:client_url).first
    # Make sure links work for identified clients as well
    internal_url = internal_url.gsub('deidentified', 'identified') unless internal_url.blank? || project_client.is_deidentified?
    url = internal_url || Config.get(:warehouse_url) + "/clients/#{remote_id}"
    return url.gsub(':client_id:', remote_id.to_s) if url
  end

  private def from_hmis?
    project_client&.from_hmis?
  end

  def warehouse_id
    remote_id if from_hmis?
  end

  def has_full_housing_release?(route = nil) # rubocop:disable Naming/PredicateName
    return true if route.present? && ! route.expects_roi?

    # If we have a warehouse connected, use the file tags available there
    release_tags = if from_hmis?
      Warehouse::AvailableFileTag.full_release.pluck(:name)
    else
      [Translation.translate('Full HAN Release'), 'Full HAN Release']
    end
    ([Translation.translate('Full HAN Release')] + release_tags).include? housing_release_status
  end

  # This is only here to allow the translation tool to find it for translating
  def translated_text_of_release_types
    Translation.translate('Full HAN Release')
    Translation.translate('Limited CAS Release')
  end

  def self.possible_availability_states
    states = {
      active_in_match: 'Active in a match',
      unavailable: 'Not available',
    }
    # raise 'hi'
    # MatchRoutes::Base.filterable_routes do |title, klass|
    #   states["available_for_matching_on_route_#{key}"] = "Available for matching on #{title}"
    # end
    return states
  end

  def clients_that_fit(requirement, scope)
    requirement.clients_that_fit(scope)
  end

  def unavailable_on_all_routes?
    ufs = unavailable_as_candidate_fors.distinct.pluck(:match_route_type)
    routes = MatchRoutes::Base.active.distinct.pluck(:type)
    (routes - ufs).count.zero?
  end

  def is_available_for_matching? # rubocop:disable Naming/PredicateName
    return false if unavailable_on_all_routes?

    available
  end

  def available_text
    if is_available_for_matching?
      if available_as_candidate_for_any_route?
        'Available for matching'
      elsif active_in_match?
        'Active in a match'
      else
        'Fully matched'
      end
    else
      if unavailable_on_all_routes? # rubocop:disable Style/IfInsideElse
        'Not available on any route'
      else
        'Not available'
      end
    end
  end

  def last_ineligible_response
    client_opportunity_matches.closed.
      joins(decisions: :decline_reason).
      merge(MatchDecisionReasons::Base.ineligible_in_warehouse).
      maximum(mdr_b_t[:updated_at])&.to_date
  end

  def has_enrollments? # rubocop:disable Naming/PredicateName
    enrolled_in_th ||
    enrolled_in_sh ||
    enrolled_in_so ||
    enrolled_in_es ||
    enrolled_in_rrh ||
    enrolled_in_psh ||
    enrolled_in_ph
  end

  def structured_rrh_assessment_contact_info
    return nil unless rrh_assessment_contact_info.present?
    return OpenStruct.new(first_name: rrh_assessment_contact_info) unless rrh_assessment_contact_info.match?('^Email:')

    (first_name, last_name) = rrh_assessment_contact_info.match('^.+')&.to_s&.split(' ')
    phone = rrh_assessment_contact_info.match('^Phone:(.+)').try(:[], 1)&.strip
    email = rrh_assessment_contact_info.match('^Email:(.+)').try(:[], 1)&.strip
    address = /^Address:(.+)/m.match(rrh_assessment_contact_info).try(:[], 1)&.strip
    OpenStruct.new(
      first_name: first_name,
      last_name: last_name,
      phone: phone,
      email: email,
      address: address,
    )
  end

  def client_match_attributes
    neighborhoods = Neighborhood.where(id: neighborhood_interests).pluck(:name)&.to_sentence.presence || 'Any'
    {
      'Neighborhood Preference' => neighborhoods,
    }
  end

  # Export related
  def dv_for_export
    numeric_bool_for_export(domestic_violence)
  end

  def disabling_condition_for_export
    bool_for_export(disabling_condition)
  end

  def line_1_for_export
    address_for_export&.line1 || address # If we correctly parsed the string, it will have a line1, otherwise just echo back what was recorded
  end

  def line_2_for_export
    '' # We don't have these yet
  end

  def city_for_export
    address_for_export&.city
  end

  def state_for_export
    address_for_export&.state
  end

  def postal_code_for_export
    address_for_export&.postal_code
  end

  def primary_contact_first_name
    contacts_for_export[:primary]&.first_name
  end

  def primary_contact_last_name
    contacts_for_export[:primary]&.last_name
  end

  def primary_contact_user_agency_name
    contacts_for_export[:primary]&.user&.agency&.name
  end

  def primary_contact_email
    contacts_for_export[:primary]&.email
  end

  def primary_contact_phone
    contacts_for_export[:primary]&.phone
  end

  def secondary_contact_first_name
    contacts_for_export[:secondary]&.first_name
  end

  def secondary_contact_last_name
    contacts_for_export[:secondary]&.last_name
  end

  def secondary_contact_email
    contacts_for_export[:secondary]&.email
  end

  def secondary_contact_phone
    contacts_for_export[:secondary]&.phone
  end

  def family_member_for_export
    bool_for_export(family_member)
  end

  def majority_sheltered_for_export
    return 'Sheltered' if majority_sheltered
    return 'Unsheltered' if majority_sheltered == false
  end

  def youth_rrh_desired_for_export
    bool_for_export(youth_rrh_desired)
  end

  def dv_rrh_desired_for_export
    bool_for_export(dv_rrh_desired)
  end

  def sro_ok_for_export
    bool_for_export(sro_ok)
  end

  def requires_wheelchair_accessibility_for_export
    bool_for_export(requires_wheelchair_accessibility)
  end

  def requires_elevator_access_for_export
    bool_for_export(requires_elevator_access)
  end

  def veteran_status_for_export
    numeric_bool_for_export(veteran_status)
  end

  def neighborhood_interests_for_export
    Neighborhood.where(id: neighborhood_interests).pluck(:name).join('; ')
  end

  def need_daily_assistance_for_export
    bool_for_export(need_daily_assistance)
  end

  private def numeric_bool_for_export(value)
    return 'Yes' if value.to_s == '1'
    return 'No' if value.to_s == '0'
  end

  private def bool_for_export(value)
    return '' if value.nil?
    return 'Yes' if value

    'No'
  end

  private def contacts_for_export
    @contacts_for_export ||= {}.tap do |ec|
      export_contacts = project_client&.shelter_agency_contacts
      primary_contact = export_contacts&.first
      secondary_contact = export_contacts&.second
      primary_contact.email = primary_contact&.user&.email if primary_contact
      secondary_contact.email = secondary_contact&.user&.email if secondary_contact
      # Attempt to find a useful contact for the client, the format of these is not conducive to exporting
      if primary_contact
        secondary_contact ||= structured_rrh_assessment_contact_info
      else
        primary_contact = structured_rrh_assessment_contact_info
      end
      if primary_contact
        secondary_contact ||= OpenStruct.new(first_name: case_manager_contact_info)
      else
        primary_contact = OpenStruct.new(first_name: case_manager_contact_info)
      end
      ec[:primary] = primary_contact
      ec[:secondary] = secondary_contact
    end
  end

  private def address_for_export
    @address_for_export ||= StreetAddress::US.parse(address)
  end
  # End export related

  def self.sort_options(show_vispdat: false, show_assessment: false)
    [
      { title: 'Last name A-Z', column: 'last_name', direction: 'asc', order: 'LOWER(last_name) ASC', visible: true },
      { title: 'Last name Z-A', column: 'last_name', direction: 'desc', order: 'LOWER(last_name) DESC', visible: true },
      { title: 'First name A-Z', column: 'first_name', direction: 'asc', order: 'LOWER(first_name) ASC', visible: true },
      { title: 'First name Z-A', column: 'first_name', direction: 'desc', order: 'LOWER(first_name) DESC', visible: true },
      { title: 'Youngest to oldest', column: 'date_of_birth', direction: 'desc', order: 'date_of_birth DESC', visible: true },
      { title: 'Oldest to youngest', column: 'date_of_birth', direction: 'asc', order: 'date_of_birth ASC', visible: true },
      { title: 'Homeless days', column: 'days_homeless', direction: 'desc', order: 'days_homeless DESC', visible: true },
      { title: 'Most served in last three years', column: 'days_homeless_in_last_three_years', direction: 'desc',
        order: 'days_homeless_in_last_three_years DESC', visible: true },
      { title: 'Longest standing', column: 'calculated_first_homeless_night', direction: 'asc',
        order: 'calculated_first_homeless_night ASC', visible: true },
      { title: 'Assessment score', column: 'assessment_score', direction: 'desc', order: 'assessment_score DESC', visible: show_assessment },
      { title: 'VI-SPDAT score', column: 'vispdat_score', direction: 'desc', order: 'vispdat_score DESC', visible: show_vispdat },
      { title: 'Priority score', column: 'vispdat_priority_score', direction: 'desc', order: 'vispdat_priority_score DESC', visible: true },
    ]
  end

  def self.log message
    Rails.logger.info message
  end
end
